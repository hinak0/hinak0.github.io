---
title: Clash内核开发进度
categories:
  - 通信網
date: 2023-12-30 16:00:04
tags:
cover:
---

这个周基本没干别的，全在clash的定制化上花时间了，下面总结一下进度。

## ClashConfigConverter

一个轻量化的基于 Golang 的 Clash 订阅链接转换器。支持以下功能：

- 精确到单个订阅链接的 udp 控制与请求头自定义
- 读取自定义的本地规则列表
- 预加载节点
- 正则排除节点

目前只能算一个半成品，没有做太多测试，也没有写readme，项目已经开源：

https://github.com/hinak0/ClashConfigConverter

有时间打磨一下。

## Clash

对开源clash内核的二次开发。

开发遵循以下几个原则：

- 兼容现有的配置文件格式
- 沿袭现有的项目结构，只做加减法。
- 代码可读性与性能同样重要

clash采用总线模式组织代码，各个模块相对独立，总线也就是hub模块。

1. 总线负责解析配置文件，触发全局热更新
2. 总线向各个子模块传递参数，一般只包括基本类型，constant类型，以及配置文件。
3. 各个子模块之间不相互引用，需要的数据类型定义在constant模块里。

### 远端解析功能

之前就发现clash所有的dns解析都是直接解析，如果配置了境外的dns，解析速度就要打折扣，更多时候境外dns根本不通，必须等到5秒超时时间。（尤其是配置了fallback,而且fallback全是境外dns的时候）。

于是开发一个dns自定义传输层（也就是远端解析）的功能，就军训上面的原则，开发有以下几个步骤：

1. 不能直接引用tunnel中的函数（模块之间要相互独立），而是由总线传入一个ConnContext的通道，传输层使用这个通道
2. 需要的ConnContext由总线传入dns模块。
3. 在inbound模块新建一个newINVODKE方法，用于创建invoke的net.conn对象
4. 最后将创建好的net.conn用在需要的传输层自定义方法。

相对于之前的直接走本机监听地址，有以下几点优点：

1. 使用net.Pipe()，在内存中进行数据交换，减少了系统调用，优化了性能。
2. 避免了硬编码，或者跨层读取配置文件来获得代理地址。
3. 新增的invoke调用或许可以用于后面的其他模块。

这个功能目前运行良好，体感上响应速度快了不少，但是存在以下几个问题。

1. outbound的dns解析也要依赖resolver来进行，但是resolver解析需要outbound就循环了。[解决办法是至少配置一个境内dns，直接命中direct]
2. 如果outbound的延迟太高，仍然要等5秒超时时间。[这个也不是代码可以解决的问题]

~~下一步打算优化：命中代理的域名直接使用fallback，不使用mainserver。~~[已实现]

### 优化日志表现

考虑到clash本身有完善的控制面板api，本着"没有日志就是运行正常"的理念，去除了大部分无用的正常日志输出，加强了各种错误日志输出，更有利于掌握运行状态。

### 重构resolver模块(2024/01/03更新)

针对resolver模块，进行了代码重构，对resolver增加参数`ResolvePolicy`，可以指定解析策略。

- Unspecified 未指定，遵循以前的policy服务器->main&fallback服务器流程。
- DefaultOnly 只使用默认服务器（不加密的直连境内dns）
- MainOnly 只使用主要服务器（境内加密dns）
- FallbackOnly 只使用fallback服务器（境外加密dns）
- 后面有需要可以加入其他的策略，如Mainfirst等。

同时现在由于远端解析功能+可以指定解析策略，整个boot的解析链是这样的：

1. default必须是dns协议的直连服务器
2. main与fallback交给default解析
3. 其他的outbound交给main解析
4. 入站流量根据规则匹配情况，交给main或者fallback解析

之前提到的*命中代理的域名直接使用fallback*已经实现了，但是有一定的限制：由于match中部分rule(比如IP-CIDR,GEOIP等)需要解析ip才可以进行匹配，这时候只能使用`Unspecified Policy`进行解析。

不过好在IP-CIDR一般有no-resolve配置项，GEOIP一般在规则集末尾位置，这个倒不怎么影响指定策略解析。

现在境内流量解析只走境内，境外流量解析只走境外，有这么几个好处：

1. 降低系统负载，需要发送的解析减少
2. 可以享受dns加速，优化流量路径。
3. 减少隐私泄露，现在解析过程，default只解析几个加密dns地址，main只解析境内地址，fallback只解析境外地址，可以说是最小化了dns解析导致的数据泄露。

现在已知有几个issue，但是对于我个人使用没有影响，没有动力去完善了：

1. tls协议没有实现远端解析
2. GLOBAL模式和DIRECT模式不可用(由于dns解析功能的限制，global模式和direct模式破坏了解析链。其实已经有几个解决方案了[比如invoke指定SpecialProxy，或者创建新的tunnel队列]，~~但是不够优雅，暂时就不去完善了~~[已完成]。)
3. ~~具体的outbound实现，有可能直接把host给proxy（比如ss协议），算是一种性能损失（解析两遍）；还会泄露隐私；还有爱国节点屏蔽~~[已解决]。

### 细节完善（2024/1/12更新）

上面提到的一些问题，已经解决了：

- 关于global模式与direct模式，最总采用了dns指定specialProxy的方式实现，最终还是改变了配置文件格式。
- outbould主要通过metadata.AddrType()辨别通过ip还是域名，通过修改这个函数实现ip优先。
- outbound实现一个新的钩子函数用来解析host，除了direct外全部使用fallback解析。

完善版本已经使用接近一个周了，没发现什么问题。
