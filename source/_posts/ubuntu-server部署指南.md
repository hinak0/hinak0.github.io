---
title: Ubuntu server部署指南
date: 2022-12-05
categories:
  - 搞机
---

## 路由器必须有的3个功能

- dns

- dhcp

- nat

## 怎么做

- 使用`dnsmasq`实现dhcp和dns

- 使用`iptables`实现nat转发

- 使用`clash+iptables`实现透明代理

## dnsmasq配置

首先关闭系统的dns-resolve服务

```bash
systemctl stop systemd-resolved
systemctl disable systemd-resolved
systemctl mask systemd-resolved
```

然后配置dnsmasq服务

```conf
port=53
interface=enp3s0

dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.1
dhcp-range=192.168.1.129,192.168.1.192,255.255.255.0,24h

dhcp-option=tag:proxy,option:dns-server,192.168.1.2
dhcp-option=tag:proxy,option:router,192.168.1.2
dhcp-range=tag:proxy,192.168.1.65,192.168.1.127,255.255.255.0,24h

server=223.5.5.5
server=119.29.29.29

no-resolv
domain=lan
local=/lan/

# log-queries
# log-facility=/var/log/dnsmasq.log

dhcp-host=<mac>,<ip>,<domain name>,<tag>
...
```

## iptables规则

```bash
# 实现nat
iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
```

这时候下游主机就可以正常上网了

## clash配置

```yaml
port: ****
redir-port: ****
tproxy-port: ****
allow-lan: true
mode: rule
log-level: error
ipv6: false
external-controller: 127.0.0.1
external-ui: /var/www/html/
secret: secret
profile:
  store-selected: false
  store-fake-ip: false
dns:
  enable: true
  listen: :**
  ipv6: false
  default-nameserver:
    - 127.0.0.1
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  use-hosts: false
  fake-ip-filter:
    - *.lan
  nameserver:
    - https://dns.alidns.com/dns-query
  fallback:
    - https://doh.dns.sb/dns-query
    - https://dns.cloudflare.com/dns-query
  fallback-filter:
    geoip: true
    geoip-code: CN
  nameserver-policy:
    +.lan: 127.0.0.1
```

## iptables选择性转发流量到clash

iptables配置要点：

- 向wan的流量redir

- 向lan的流量accept

- 向server的dns redir 到 tproxy port

```bash
#!/bin/bash
#!/bin/bash

dns_port=0
redir_port=0
tproxy_port=0

udp_enable=1
nat_enable=0
slient_wan=0

inbound=enp3s0
outbound=enp4s0

config_dir="/var/local/clash"
converter_dir="/home/chlen/converter"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"

# error break
# set -e
# line-number for debug
# set -x
init() {
	# route rules
	ip rule add fwmark 1 table 100
	ip route add local 0.0.0.0/0 dev lo table 100

	# not global addresses
	ipset create local hash:net
	ipset add local 0.0.0.0/8
	ipset add local 10.0.0.0/8
	ipset add local 100.64.0.0/10
	ipset add local 127.0.0.0/8
	ipset add local 169.254.0.0/16
	ipset add local 172.16.0.0/12
	ipset add local 192.168.0.0/16
	ipset add local 224.0.0.0/4
	ipset add local 240.0.0.0/4

	setRules
}

clearAllRules() {
	# recovery rules
	iptables-save | awk '/^[*]/ { print $1 } /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; } /COMMIT/ { print $0; }' | iptables-restore

	# nat
	if [ $nat_enable -eq 1 ]; then
		iptables -t nat -A POSTROUTING -o $outbound -j MASQUERADE
	fi

	# drop initiative package from wan
	if [ $slient_wan -eq 1 ]; then
		iptables -A INPUT -i $outbound -m state --state NEW -j DROP
	fi
}

setRules() {
	clearAllRules

	# udp tproxy
	iptables -t mangle -N PROXY_UDP
	iptables -t mangle -F PROXY_UDP
	iptables -t mangle -A PROXY_UDP -p udp --dport 53 -j ACCEPT
	iptables -t mangle -A PROXY_UDP -p udp -j TPROXY --on-port ${tproxy_port} --tproxy-mark 1

	# DNS redirect
	iptables -t nat -N PROXY_DNS
	iptables -t nat -F PROXY_DNS
	iptables -t nat -A PROXY_DNS -p udp -j REDIRECT --to-ports ${dns_port}

	# tcp redirect
	iptables -t nat -N PROXY_TCP
	iptables -t nat -F PROXY_TCP
	iptables -t nat -A PROXY_TCP -p tcp -j REDIRECT --to-ports ${redir_port}

	# apply rules
	if [ $udp_enable -eq 1 ]; then
		if [ $nat_enable -eq 1 ]; then
			iptables -t mangle -A PREROUTING -s 192.168.1.128/25 -j ACCEPT
		fi
		iptables -t mangle -A PREROUTING -m set --match-set local dst -j ACCEPT
		iptables -t mangle -A PREROUTING -p udp -j PROXY_UDP
	fi

	# apply rules
	if [ $nat_enable -eq 1 ]; then
		iptables -t nat -A PREROUTING -s 192.168.1.128/25 -j ACCEPT
	fi
	iptables -t nat -A PREROUTING -p udp --dport 53 -j PROXY_DNS
	iptables -t nat -A PREROUTING -m set --match-set local dst -j ACCEPT
	iptables -t nat -A PREROUTING -p tcp -j PROXY_TCP
}

setSelf() {
	iptables -t nat -A OUTPUT -m mark --mark 6666 -j ACCEPT
	iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports ${dns_port}
	iptables -t nat -A OUTPUT -m set --match-set local dst -j ACCEPT
	iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports ${redir_port}
}

update() {
	cd $converter_dir
	cat $config_dir/config.yaml >$config_dir/past.yaml

	./converter

	diffConfig

	read -p "Press Enter to continue..."

	cat $config_dir/target.yaml >$config_dir/config.yaml
	# setRules
	systemctl restart clash
}

lease() {
	# show dnsmasq lease
	while read line; do
		timestamp=$(echo "$line" | awk '{print $1}')
		mac=$(echo "$line" | awk '{print $2}')
		ip=$(echo "$line" | awk '{print $3}')
		host=$(echo "$line" | awk '{print $4}')

		# Convert the timestamp to a human-readable date
		date=$(date -d @$timestamp +"%m-%d %H:%M:%S")

		# Output the result
		echo "$mac	$date	$ip	$host"
	done <"$LEASE_FILE"
}

ban() {
	iptables -t mangle -I PREROUTING -s $1 -j DROP
	# iptables -A INPUT -s $1 -j DROP
	# iptables -I FORWARD -s $1 -j DROP
	# iptables -I FORWARD -s $1 -p tcp --dport 443 -j ACCEPT
	# iptables -I FORWARD -s $1 -p tcp --dport 80 -j ACCEPT
}

diffConfig() {
	# diff $config_dir/config.yaml $config_dir/target.yaml -C 3 --color | less
	diff $config_dir/config.yaml $config_dir/target.yaml -C 3 --color
}

recovery() {
	cat $config_dir/past.yaml >$config_dir/config.yaml
	systemctl restart clash
}

case "$1" in
init)
	init
	;;
set)
	setRules
	;;
del)
	clearAllRules
	;;
update)
	update
	;;
lease)
	lease
	;;
recovery)
	recovery
	;;
diff)
	diffConfig
	;;
ban)
	ban $2
	;;
*)
	echo "HELLO IT'S ME"
	exit 0
	;;
esac
exit
```

## 持久化

### 注册账户

```bash
sudo useradd -d /var/local/clash -r clash
```

### 注册clash为服务

```bash
vim /etc/systemd/system/clash.service
```

写入

```ini
[Unit]
Description=clash daemon
After=network.target

[Service]
User=clash
Type=simple
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_BIND_SERVICE CAP_NET_ADMIN
WorkingDirectory=/var/local/clash/
ExecStart=/usr/local/bin/clash -d /var/local/clash/
Restart=on-failure
RestartSec=600s

[Install]
WantedBy=multi-user.target
```

开机自启动

```bash
systemctl start clash.service
systemctl enable clash.service
```

### iptables规则保存[可选]

```bash
iptables-save > /etc/iptables
```
