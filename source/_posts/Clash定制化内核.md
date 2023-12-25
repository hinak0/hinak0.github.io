---
title: Clash定制化内核
categories:
  - 通信網
date: 2023-11-05 15:04:14
tags:
cover: images/20231105-150642.png
---

一觉醒来，我Clash呢？！

![](images/20231105-150642.png)

不仅仅是cfw,整个clash系列，从内核到各种客户端无一幸免。

作者进局子了，这clash看来是不能用了，短期可能被迫提供软件漏洞，长期代码失去维护。

于是决定更换到v2ray。

## 更换到V2Ray

### 配置

[V2Ray 配置指南](https://guide.v2fly.org/)

[透明代理(TPROXY)](https://guide.v2fly.org/app/tproxy.html)

[路由功能](https://guide.v2fly.org/basics/routing/basics_routing.html)

嗯，不错，基本功都都能实现。

### 问题

但是接下来发现一些问题

首先是subconverter只能转换订阅成为`vmess://`的列表，没有找到直接转换成`config.json`的办法，非常不方便。

然后打算使用现有的完备客户端，但是没有找到合适的运行在`linux server`的web客户端。

最后就是没发现v2ray有自动测速，自动选择之类的配置，不太方便。

总结下来，都不是大问题，但是，我懒得搞了。

现在这一套`clash core + subconverter + iptables`的模式先用着。

至于可能被迫提供0day漏洞，我觉得应该不至于，本人一直用的是开源版本`clash`而不是`clash premium`，软件本体不至于有后门（侥幸心理）。

还是等后面有更好的工具能满足我的需求时再换吧。

哎，翻墙穷蛆哥们的末日就快到咧。

## Clash内核定制化

于是打算在现有clash基础上进行定制化。

### make构建工具

[Make 命令教程-阮一峰的网络日志](https://www.ruanyifeng.com/blog/2015/02/make.html)

makefile的语法有些类似于shell脚本，用于指定不同target如何构建，以及构建前提条件。

通过make工具，可以很轻易的实现大型项目（并不限于c语言项目）的多构建目标的编译。

例如，以下clash项目的makefile核心语句：

```makefile
VERSION=$(shell git describe --tags --always || echo "unknown version")
BUILDTIME=$(shell date -u)
GOBUILD=CGO_ENABLED=0 go build -trimpath -ldflags '-X "github.com/Dreamacro/clash/constant.Version=$(VERSION)" \
		-X "github.com/Dreamacro/clash/constant.BuildTime=$(BUILDTIME)" \
		-w -s -buildid='

all: linux-amd64 darwin-amd64 windows-amd64 # Most used

darwin-amd64:
	GOARCH=amd64 GOOS=darwin $(GOBUILD) -o $(BINDIR)/$(NAME)-$@

darwin-amd64-v3:
	GOARCH=amd64 GOOS=darwin GOAMD64=v3 $(GOBUILD) -o $(BINDIR)/$(NAME)-$@

darwin-arm64:
	GOARCH=arm64 GOOS=darwin $(GOBUILD) -o $(BINDIR)/$(NAME)-$@

linux-386:
	GOARCH=386 GOOS=linux $(GOBUILD) -o $(BINDIR)/$(NAME)-$@
```

这段规则指定了不同构建目标的构建规则。

### 定制化

之前clash内核源代码我留有备份，最近针对于源代码进行了一些定制化，目前保存在自己的私人仓库里。

clash项目的源代码结构还是比较清晰的，做一些二次开发也比较容易，以后有新的协议也许可以开发一下兼容，自己的代码用起来比较安心。

![已经部署到网关了](images/20231219-151516.png)

目前做了这些：

- 自定义配置文件目录
- 精简`Country.mmdb`，优化查询性能
- 优化`cache.db`逻辑
- 自定义规则追溯监控

下一步打算做的：

- ~~`udp: false`配置项不知道在哪个版本开始无效了，udp全走规则了。下一步打算修一下这个bug~~[已解决]
- doh通过代理进行远端查询

  现在的doh查询没有走代理，导致境外的doh根本不好使，境内的又有污染，根本不好用。

  下一步打算是doh走代理呢，还是全部fallback都走代理呢，还要再看。

  听说clashMeta支持这个功能，也许可供参考。

#### udp配置项无效

翻一翻源代码，可以在`match()`中找到：

```golang
func match(metadata *C.Metadata) (C.Proxy, C.Rule, error) {

	// ....

	if rule.Match(metadata) {
		adapter, ok := proxies[rule.Adapter()]
		if !ok {
			continue
		}
		if metadata.NetWork == C.UDP && !adapter.SupportUDP() && UDPFallbackMatch.Load() {
			log.Debugln("[Matcher] %s UDP is not supported, skip match", adapter.Name())
			continue
		}
		return adapter, rule, nil
	}

	return proxies["DIRECT"], nil, nil
}
```

可以看到，adapter不支持udp的情况下还需要开启`UDPFallbackMatch`这个配置项，具体配置文件是这样的：

```yaml
experimental:
  udp-fallback-match: true
```

离谱的是，没有任何文档中有对这个配置项的描述，即使相关文档的最后编辑日期要后于`udp-fallback-match`的加入日期。

文档中的实验性功能一节，介绍了一个已经弃用的`sniff-tls-sni`。

但是这个功能的加入对整个项目的用户影响还是蛮大的（比如我就希望udp直连），但是除非去慢慢翻源代码，你不可能知道还有个配置项可以把这个关了。

有点坑。
