---
title: "windows网络连接后面的数字怎么去掉"
date: "2022-09-30"
categories:
  - "网络工程"
---

[win8/win10无线网络名称后面的数字怎么删掉或修改?](https://www.zhihu.com/question/21109663)

windows所有连接过的网络都保存在这两个位置:

```
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\NetworkList\Profiles
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsNT\CurrentVersion\NetworkList\Signatures\Unmanaged
```

并没有提供删除方式，连接到ssid相同的网络时会在后面加上数字，强迫症表示强烈谴责。
