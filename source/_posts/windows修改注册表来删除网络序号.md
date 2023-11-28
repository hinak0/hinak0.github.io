---
title: windows修改注册表来删除网络序号
date: 2022-09-30
categories:
  - 搞机
---

windows注册表不是一个太好的设计，个人更喜欢unix系统里的配置文件。

[win8/win10无线网络名称后面的数字怎么删掉或修改?](https://www.zhihu.com/question/21109663)

windows所有连接过的网络都保存在这两个位置:

```
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged
```

并没有提供删除方式，连接到ssid相同的网络时会在后面加上数字，分别不同网络。

删掉就行。
