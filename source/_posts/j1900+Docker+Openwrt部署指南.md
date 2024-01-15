---
title: j1900+Docker+Openwrt部署指南
date: 2022-10-20
categories:
  - 通信網
---

## 安装系统

### 环境配置

`sudo vim /etc/profile`\\

```bash
sudo vim /etc/environment

EDITOR="vim"

http_proxy=""
https_proxy=""
no_proxy="192.168.1.1/24,10.92.128.1/18,.lan"
```

### 时区

`sudo tzselect`

`sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime`

### 配置apt镜像源[可选]

`sudo vim /etc/apt/sources.list`

```conf
# https://mirrors.tuna.tsinghua.edu.cn/
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
```

### ubuntu配置静态ip

- `vim /etc/netplan/00-netcfg.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      dhcp4: false
      dhcp6: false
      accept-ra: false
      addresses:
        - 192.168.1.2/24
      link-local: []
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 127.0.0.1
        search:
          - ".lan"
    enp4s0:
      optional: true
      dhcp4: true
      dhcp6: true
```

- `sudo netplan apply`

## docker配置

- `sudo apt-get update`
- `sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common`
- `sudo curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -`
- `sudo apt-get install docker-ce docker-ce-cli containerd.io`

## docker部署openwrt

### macvlan模式

1.打开网卡混杂模式

`sudo ip link set enp3s0 promisc on`

`sudo ip link set enp4s0 promisc on`

2.创建网络

`docker network create -d macvlan -o parent=enp3s0 vlan`

`docker network create -d macvlan -o parent=enp4s0 vwan`

3.拉取镜像

`docker pull registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64`

4.创建并启动容器

`docker run --name openwrt -d --network none --privileged registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 /sbin/init`

5.连接网络

`docker network connect vlan openwrt`

`docker network connect vwan openwrt`

6.进入容器并修改相关参数(修改固定ip)

`docker exec -it openwrt bash`

`vim /etc/config/network`

7.重启

`/etc/init.d/network restart`

### host模式(网络性能更好)

1.拉取镜像

`docker pull registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64`

[OpenWrt-Docker 项目地址](https://github.com/SuLingGG/OpenWrt-Docker)

2.创建并启动容器\\

```bash
docker run --name openwrt \
-v /mnt/share:/mnt/share \
-d --network host --privileged \
registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 \
/sbin/init
```

3.进入容器并修改相关参数

`docker exec -it openwrt bash`

`vim /etc/config/network`

```conf
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option packet_steering '1'

config interface 'lan'
        option proto 'static'
        option ifname 'enp3s0'
        option ipaddr '192.168.1.1'
        option netmask '255.255.255.0'

config interface 'wan'
        option proto 'dhcp'
        option ifname 'enp4s0'
        option hostname 'openwrt
```

4.重启

`/etc/init.d/network restart`

## 注意

1.修改配置前先备份原本的配置文件

2.docker的openwrt尽量注意避免与主系统冲突，比如不要让主系统和openwrt同时自动挂载设备，可能产生冲突。

## 参考

[菜鸟教程](https://www.runoob.com/docker/ubuntu-docker-install.html)

[美丽应用](https://mlapp.cn/376.html)
