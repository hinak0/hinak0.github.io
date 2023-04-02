---
title: "Ubuntu server作路由器"
date: "2022-12-05"
categories:
  - "网络工程"
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
port=53
interface=enp3s0
dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.1
dhcp-range=192.168.1.2,192.168.1.254,255.255.255.0,24h
strict-order

cache-size=2048
server=223.5.5.5
no-resolv

domain=lan
local=/lan/

# log-queries
# log-facility=/var/log/dnsmasq.log

dhcp-host=<mac>,<ip>,<domain name>
...
```

## iptables规则

```
# 实现nat
iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
```

这时候下游主机就可以正常上网了

## clash配置

```
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
    - "*.lan"
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

- 向server的dns redir 到　tproxy port

```bash
#!/bin/bash

dns_port=0
redir_port=0
tproxy_port=0
udp_enable=1
config_dir="/var/local/clash"
subconverter_dir="/usr/local/lib/subconverter"
sub_link="http://127.0.0.1:25500/getprofile?name=profiles"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"

# error break
set -e
# line-number for debug
set -x
init() {
        # route rules
        ip rule add fwmark 1 table 100
        ip route add local 0.0.0.0/0 dev lo table 100

        # not global addresses
        ipset create local hash:net
        ipset add local 0.0.0.0/8
        ipset add local 127.0.0.0/8
        ipset add local 10.0.0.0/8
        ipset add local 169.254.0.0/16
        ipset add local 192.168.0.0/16
        ipset add local 224.0.0.0/4
        ipset add local 240.0.0.0/4
        ipset add local 172.16.0.0/12
        ipset add local 100.64.0.0/10
}
clearAllRules() {
        # recovery rules
        iptables-save | awk '/^[*]/ { print $1 } /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; } /COMMIT/ { print $0; }' | iptables-restore
        # nat
        iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
        # drop initiative package from wan
        iptables -A INPUT -i enp4s0 -m state --state NEW -j DROP
}
setProxy() {
        clearAllRules

        # udp tproxy
        iptables -t mangle -N CLASH_UDP
        iptables -t mangle -F CLASH_UDP
        iptables -t mangle -A CLASH_UDP -p udp --dport 53 -j ACCEPT
        iptables -t mangle -A CLASH_UDP -p udp -j TPROXY --on-port ${tproxy_port} --tproxy-mark 1

        # DNS redirect
        iptables -t nat -N CLASH_DNS
        iptables -t nat -F CLASH_DNS
        iptables -t nat -A CLASH_DNS -p udp -j REDIRECT --to-ports ${dns_port}

        # tcp redirect
        iptables -t nat -N CLASH_TCP
        iptables -t nat -F CLASH_TCP
        iptables -t nat -A CLASH_TCP -p tcp -j REDIRECT --to-ports ${redir_port}

        # apply rules
        if [ $udp_enable -eq 1 ]; then
                iptables -t mangle -A PREROUTING -s 192.168.1.128/25 -j ACCEPT
                iptables -t mangle -A PREROUTING -m set --match-set local dst -j ACCEPT
                iptables -t mangle -A PREROUTING -p udp -j CLASH_UDP
        fi

        # apply rules
        iptables -t nat -A PREROUTING -s 192.168.1.128/25 -j ACCEPT
        iptables -t nat -A PREROUTING -p udp --dport 53 -j CLASH_DNS
        iptables -t nat -A PREROUTING -m set --match-set local dst -j ACCEPT
        iptables -t nat -A PREROUTING -p tcp -j CLASH_TCP
}
setSelf() {
        #　Not recommended
        iptables -t nat -A OUTPUT -m mark --mark 6666 -j ACCEPT
        iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports ${dns_port}
        iptables -t nat -A OUTPUT -m set --match-set local dst -j ACCEPT
        iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports ${redir_port}
}
update() {
        # extra
        cd $subconverter_dir
        ./subconverter &
        sleep 3
        cat $config_dir/config.yaml > $config_dir/past.yaml
        echo "# `date`" > $config_dir/config.yaml
        curl $sub_link -s --noproxy '*' >> $config_dir/config.yaml
        pkill subconverter

        # test
        clash -d $config_dir -t
        if [ $? -ne 0 ]; then
                echo "update failed."
        else
                echo "update seccussfully!"
                # setProxy
                systemctl restart clash
                diffConfig
        fi
}
lease(){
        set +x
        # show dnsmasq lease
        while read line; do
                timestamp=$(echo "$line" | awk '{print $1}')
                mac=$(echo "$line" | awk '{print $2}')
                ip=$(echo "$line" | awk '{print $3}')
                host=$(echo "$line" | awk '{print $4}')

                # Convert the timestamp to a human-readable date
                date=$(date -d @$timestamp +"%m-%d %H:%M:%S")

                # Output the result
                echo "$mac      $date   $ip     $host"
        done < "$LEASE_FILE"
}

ban(){
        # temporarily disable one ip
        iptables -t mangle -I PREROUTING -s $1 -j DROP
}
diffConfig(){
        # show diff
        colordiff -c $config_dir/past.yaml $config_dir/config.yaml
}
case "$1" in
        del)
                clearAllRules
                ;;
        set)
                setProxy
                ;;
        update)
                update
                ;;
        init)
                init
                ;;
        self)
                setSelf
                ;;
        lease)
                lease
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

### 注册clash为服务

```cmd
vim /etc/systemd/system/clash.service
```

写入

```service
[Unit]
Description=clash daemon

[Service]
User=clash
Type=simple
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_ADMIN
AmbientCapabilities=CAP_NET_BIND_SERVICE CAP_NET_ADMIN
WorkingDirectory=/var/local/clash/
ExecStart=/usr/local/bin/clash -d /var/local/clash/
Restart=on-failure
RestartSec=20s

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
