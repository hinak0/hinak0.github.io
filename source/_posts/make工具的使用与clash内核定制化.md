---
title: make工具的使用与clash内核定制化
categories:
  - Code & Program
date: 2023-12-19 14:53:49
tags:
cover: images/20231219-151516.png
---

## make构建工具

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

## clash内核定制化

之前clash内核源代码我留有备份，最近针对于源代码进行了一些定制化，目前保存在自己的私人仓库里。

clash项目的源代码结构还是比较清晰的，做一些二次开发也比较容易，以后有新的协议也许可以开发一下兼容，自己的代码用起来比较安心。

![已经部署到网关了](images/20231219-151516.png)
