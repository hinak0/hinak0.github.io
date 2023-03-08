---
title: "Ubuntu server作路由器"
date: "2022-12-05"
categories:
  - "network"
---

## 路由器必须有的3个功能

- dns

- dhcp

- nat

## 我打算这么做

- 使用`dnsmasq`实现dhcp和dns

- 使用`iptables`实现nat转发

- 使用`clash+iptables`实现透明代理

## dnsmasq配置

首先关闭系统的dns-resolve服务

```
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

然后配置dnsmasq服务

```
# 配置dhcp
dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.1
dhcp-range=192.168.1.129,192.168.1.254,255.255.255.0,1h

# 配置dns
port=53
strict-order

# 静态ip以及host
dhcp-host=00:11:22:33:44:55,192.168.1.2,hinak0,infinite
...
```

## iptables规则

如果只是想做nat,只需要一条规则即可

```
# 网卡填自己的wan口
iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
```

这时候下游主机就可以正常上网了
下面配置透明代理

## clash配置

```
port: 7890
socks-port: 7891
redir-port: 7892
allow-lan: true
ipv6: false
mode: Rule
log-level: warning
external-controller: 192.168.1.1:80
secret: ""
# ui自己编译一下就可以了
external-ui: /home/chlen/.config/clash/dist/
hosts:
  'server': 192.168.1.1
  'hinak0': 192.168.1.2
  'miui': 192.168.1.3
dns:
  enable: true
  ipv6: false
  listen: 0.0.0.0:5354
  enhanced-mode: redir-host
  # fake-ip-range: 198.18.0.1/16
  default-nameserver:
    - 114.114.114.114
    - 8.8.8.8
  nameserver:
    - 114.114.114.114 # default value
    - 8.8.8.8 # default value
    - tls://dns.rubyfish.cn:853 # DNS over TLS
    - https://1.1.1.1/dns-query # DNS over HTTPS
```

这时候主机手动填写系统代理，就可以走代理，但这不是我想要的无感代理,下面配置透明代理

## iptables选择性转发流量到clash

iptables配置要点：

- 所有需要的lan流量都发送到proxy

- 所有目标是lan段的流量都放行

- lan口需要的dns请求都拦截到proxy\_dns,防止dns污染

```
#!/bin/bash

lan_ipaddr="192.168.1.1" # 局域网路由器IP地址
dns_port="5354"          # DNS转发服务端口
redir_port="7892"        # 透明代理转发端口

clearAllRules() {
		# 这里是清除所有规则回到默认状态
        iptables-save | awk '/^[*]/ { print $1 }
                                                        /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; }
    /COMMIT/ { print $0; }' | iptables-restore
	 	# 这里是配置nat使下游上网
        iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
}
setProxy() {
        # 转发DNS请求到端口 dns_port 解析
        iptables -t nat -N CLASH_DNS
        iptables -t nat -F CLASH_DNS

        iptables -t nat -A CLASH_DNS -p udp -s ${lan_ipaddr}/24 --dport 53 -j REDIRECT --to-ports ${dns_port}

        iptables -t nat -A PREROUTING -p udp -s ${lan_ipaddr}/25 --dport 53 -j CLASH_DNS

        # tcp代理
        iptables -t nat -N CLASH
        iptables -t nat -F CLASH

        # 目标是lan网段直连
        iptables -t nat -A CLASH -p tcp -d ${lan_ipaddr}/24 -j RETURN

        # 源于lan的包重定向到CLASH
        iptables -t nat -A CLASH -p tcp -s ${lan_ipaddr}/24 -j REDIRECT --to-ports ${redir_port}

        # 让CLASH链生效
        iptables -t nat -A PREROUTING -p tcp -s ${lan_ipaddr}/25 -j CLASH
}

case "$1" in
clear)
        clearAllRules
        echo "delete rules successfully"
        ;;
set)
        clearAllRules
        setProxy
        echo "set rules successfully"
        ;;
*)
        echo "usage: $0 clear|set"
        exit 0
        ;;
esac
exit
```

## 持久化

### 注册clash为服务

```
vim /etc/systemd/system/clash.service
```

写入

```
[Unit]
Description=clash daemon

[Service]
Type=simple
User=root
ExecStart=/usr/bin/clash -d /home/chlen/.config/clash/
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

开机自启动

```
systemctl start clash.service
systemctl enable clash.service
```

### iptables规则保存

```
iptables-save > /etc/iptables
```
