---
title: Redmi Note 8 Pro 刷机记录&指南
categories:
  - Others
date: 2023-08-12 20:27:17
tags:
cover: images/20230812-211529.png
---

## Before

[《工业和信息化部关于开展移动互联网应用程序备案工作的通知》解读](https://www.gov.cn/zhengce/202308/content_6897437.htm)

> **网络接入服务提供者**、应用分发平台、智能终端生产企业不得为未履行备案手续的APP提供网络接入、分发、预置等服务。
>
> APP主办者、**网络接入服务提供者**、应用分发平台、智能终端生产企业应当建立健全违法违规信息监测和处置机制，发现法律、行政法规禁止发布或者传输的信息，应当立即停止传输该信息，采取消除等处置措施，防止信息扩散，保存有关记录，并向电信主管部门报告，依据电信主管部门要求进行处置。

这个通知真的是大的来了，如果严格执行起来，就是网络白名单制度（虽然大概率烂尾）。不过今天不讨论这个，至少以后国产安卓系统是不能用了，还有这个：

[MIUI系统组件监听，“隐身”模式跟踪用户，网友：国产机的恐惧](https://zhuanlan.zhihu.com/p/649175786)

> 据早前英国每日邮报称，研究人员对安装在小米手机中的网络浏览器进行了研究，发现该浏览器正在跟踪几乎所有用户的网络行为，包括访问过的网站，Google浏览器搜索查询词条以及手机新闻显示的所有内容。
>
> 更糟糕的是，每日邮报援引《福布斯》的报道说，研究人员发现，即使手机的浏览器处于“隐身”模式，跟踪仍会持续。除浏览器外，研究人员称还发现手机记录了打开了哪些文件夹以及浏览了哪些屏幕。

虽然手头上用的是miui12.5国际版，但是还是觉得不舒服，于是赶紧给手机刷上第三方rom，这里记录一下。

## 需要解释的东西（可以避免的踩坑）

### 不要跨安卓版本刷机

> “底包”指的就是某个特定作为最低（或特定）要求的已安装安卓系统版本，或是某个作为最低（或特定）要求的已安装官方ROM版本。上面提到，卡刷是对系统和用户数据进行修补，就像打补丁一样，得先有衣服才能打补丁吧？这个“底包”就是作为底的衣服。不同的ROM间往往有许多共同的基础，如库文件、系统框架等，卡刷包发布者往往不需要将整个系统都打包进来，只打包需要修补的文件和操作的脚本就行了。因此，大几G的ROM卡刷包是卡刷包，几百兆的卡刷包也是卡刷包，完全取决于要修补的内容大小。而发包者可能是在某个/类底包上作出的修改，所以在刷卡刷包前需要先线刷/卡刷中转包满足该底包要求。

踩坑经验：最开始刷机使用的是官网的PE13系统，结果刷好遇上了这几个问题：mac地址重启更换，陀螺仪失灵，发热严重，耗电增加。不是不能用，但是总归是很难受，于是最终刷回了PE11，以上的问题才解决（除了mac地址，这个问题我没找到解决方法，虽然不影响使用）推荐在官方包同Android版本下寻找第三方rom.

总结：非必要不跨android版本，尤其是比较旧的手机，盲目刷最新版没用，且不说适配问题，硬件是跟不上的。

### Android分区

> bootloader：设备启动后，会先进入bootloader程序，这里会通过判断开机时的按键组合（也会有一些其他判断条件，暂不赘述）选择启动到哪种模式，这里主要有> Android系统、recovery模式、fastboot模式等。
> boot：包含有Android系统的kernel和ramdisk。如果bootloader选择启动Android系统，则会引导启动此分区的kernel并加载ramdisk，完成内核启动。
> system：包含有Android系统的可执行程序、库、系统服务和app等。内核启动后，会运行第一个用户态进程init，其会依据init.rc文件中的规则启动Android系统组件，> 这些系统组件就在system分区中。将Android系统组件启动完成后，最后会启动系统app —— launcher桌面，至此完成Android系统启动。
> vendor：包含有厂商私有的可执行程序、库、系统服务和app等。可以将此分区看做是system分区的补充，厂商定制ROM的一些功能都可以放在此分区。
> userdata：用户存储空间。一般新买来的手机此分区几乎是空的，用户安装的app以及用户数据都是存放在此分区中。用户通过系统文件管理器访问到的手机存储（sdcard）即此分区的一部分，是通过fuse或sdcardfs这类用户态文件系统实现的一块特殊存储空间。
> recovery：包含recovery系统的kernel和ramdisk。如果bootloader选择启动recovery模式，则会引导启动此分区的kernel并加载ramdisk，并启动其中的init继而启> 动recovery程序，至此可以操作recovery模式功能（主要包括OTA升级、双清等）。
> cache：主要用于缓存系统升级OTA包等。双清就是指对userdata分区和cache分区的清理。
> misc：主要用于Android系统和bootloader通信，使Android系统能够重启进入recovery系统并执行相应操作。

### 线刷？卡刷？

这个叫法不准确，卡刷也可以通过`adb sideload`的方法线刷，其实应该叫`Fastboot Flash`与`Recovery Install`,一个在fastboot里刷，一个在rec里刷。

卡刷一般是对系统和用户数据进行修改和替换，也有重新写入分区镜像的，一般是zip后缀。

线刷是fastboot模式下，直接覆写分区，可以解决大部分非硬件黑砖问题，一般是tar.gz后缀，解压可以看见刷机脚本。理论上可以直接运行脚本刷机，但是本人使用的是MiFlash工具。

除此之外还有深度刷机，和处理器挂钩的刷机方式，例如高通骁龙的9008,联发科的USB_PORT。作为最底层的刷机方式，一般只用于救砖（操作很复杂）。

### Redmi Note 8 Pro没有persist分区

包括官方的线刷包，以及手机本身，都没有persist分区。手机有一个persist Image分区，不要在rec里看到persist为0MB就以为是persist分区坏了，很可能是刷机包适配问题。传感器问题就线刷官方版本就能解决。

## 准备

1. [adb下载&文档](https://developer.android.com/studio/command-line/adb)

2. 下载[刷机包](https://wxdowmloads.cn/)，这里没有选择官方刷机包，是因为官方只有android13和android12的刷机包，版本选择原因后面细讲。这个下载站是酷安大佬 @无心 的刷机资源站，里面有刷机需要的大部分资源。

3. [Rec镜像](https://wxdowmloads.cn/%E7%BA%A2%E7%B1%B3Note8Pro%E5%88%B7%E6%9C%BA%E8%B5%84%E6%BA%90/TWRP)官方的twrp似乎适配有问题，换上这里的修改版就ok。

### rom版本选择

体验了几个类原生系统，比较推荐这几个：ArrowOS, LineageOS, PixelExperience. 前两者不带google全家桶，非常简洁的系统；第三个是pixel系统移植，原汁原味。本人最终选择了第三个系统。

## 刷机步骤

1. 刷入Rec(前提是解锁bootloader),fastboot模式下输入命令：

```bash
fastboot flash recovery <rec镜像路径>
fastboot reboot recovery
```

顺便一提，刷入Magisk的时候，就是覆写boot分区：

```bash
fastboot flash boot <修补过的boot.img路径>
```

2. 在rec里执行清除数据&格式化Data分区操作，这里用的rec是TWRP,也可以选择其他Rec.然后重启到Rec(格式化后重启才能挂载Data)
   ![TWRP](images/20230812-211529.png)

3. 连接电脑，将刷机包放入手机里，然后Rec选中刷机包，执行刷入工作（一般几分钟就好）。

4. OK之后继续清除数据然后启动到系统，就可以使用新的系统了。

## 可能遇到的问题

### 系统启动卡住or无限重启

尝试双清重新启动，不行就换rom。

### 刷机后系统功能不正常

rom包适配问题，依次尝试以下方案：卡刷回官方包->线刷回官方->深刷官方包。

### 耗电&发热严重

可能是rom包适配，或者Android版本太高的问题，换刷机包。

## 资源&引用

[无惧黑砖--小米联发科手动救黑砖教程［新手向］！](https://zhuanlan.zhihu.com/p/367773904) 深刷教程，希望你不会用到。
[个人安卓刷机经验（附小米6刷机指南）](https://www.bilibili.com/read/cv14189488/)
[一镜到底刷入rec，刷入类原生，海量rec及各种安卓刷机包 小米红米刷机](https://hao.0660hf.com/27792.html)

[TWRP Download](https://twrp.me/Devices/)
[无心的下载站](https://wxdowmloads.cn/) 大杂烩，又多又全（针对Note8Pro）
[MIUI Official ROMS](https://roms.miuier.com/en-us/devices/begonia/)
[Magisk](https://github.com/topjohnwu/Magisk)
