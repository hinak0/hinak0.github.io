---
title: sudoers文件损坏解决办法
date: 2023-03-13 22:31:10
categories:
  - 运维
tags:
---

今天修改sudoers文件的时候，由于没有用visudo导致文件损坏（血的教训），没法sudo了，折腾了一番。

本来打算直接su root的，可惜实在记不得密码了

后来打算用pkexec,但是遇到了`polkit-agent-helper-1: error response to policykit daemon: gdbus.error:org.freedesktop.policykit1.error.failed: no session for cookie`的错误

好在下面这篇博文帮大忙了！

链接[Ubuntu改坏sudoers后无法使用sudo的解决办法
](https://www.cnblogs.com/wayneliu007/p/10321542.html)

另外以后不能随便用vim改重要的配置文件！
