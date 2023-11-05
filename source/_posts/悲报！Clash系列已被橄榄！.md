---
title: 悲报！Clash系列已被橄榄！
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

## 配置

[V2Ray 配置指南](https://guide.v2fly.org/)

[透明代理(TPROXY)](https://guide.v2fly.org/app/tproxy.html)

[路由功能](https://guide.v2fly.org/basics/routing/basics_routing.html)

嗯，不错，基本功都都能实现。

## 问题

但是接下来发现一些问题

首先是subconverter只能转换订阅成为`vmess://`的列表，没有找到直接转换成`config.json`的办法，非常不方便。

然后打算使用现有的完备客户端，但是没有找到合适的运行在`linux server`的web客户端。

最后就是没发现v2ray有自动测速，自动选择之类的配置，不太方便。

总结下来，都不是大问题，但是，我懒得搞了。

现在这一套`clash core + subconverter + iptables`的模式先用着。

至于可能被迫提供0day漏洞，我觉得应该不至于，本人一直用的是开源版本`clash`而不是`clash premium`，软件本体不至于有后门（侥幸心理）。

还是等后面有更好的工具能满足我的需求时再换吧。

哎，翻墙穷蛆哥们的末日就快到咧。

也怪我最近没时间搞这些，过些时间再看吧！
