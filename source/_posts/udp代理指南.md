---
title: UDP代理指南
date: 2022-12-17
categories:
  - 通信網
---

## 为什么udp不能用Redirect

### redirect的原理

在nat表修改数据包的目标地址,同时netfilter有 SO_ORIGINAL_DST 选项可以支持拿到原目的地址，netfilter 会将包的原目的地址放在 socket 的 SO_ORIGINAL_DST 属性里.代理客户端依次向原目标发起请求.

### 为什么udp不能拿到修改前的地址

udp是一种无连接协议,所以没有socket来拿到修改前的地址,改了就改了.

## udp怎样实现代理

![](images/7a4d9a.png)

tproxy是在不修改数据包的前提上,将数据包转发到本地socket,但是这样不够,因为没有改数据包的目标地址,数据包就直接走forword了,所以需要增加一个路由表把所有数据转入本地:

`ip route add local 0.0.0.0/0 dev lo table 100`

然后增加一个rule,将特定的数据包转入这个路由表:

`ip rule add fwmark 1 table 100`

最后,该需要走代理的数据包加上这个标记,就可以:

`iptables -t mangle -A CLASH_UDP -p udp -j TPROXY --on-port ${tproxy_port} --tproxy-mark 1`

如果想代理本机udp,就给本地output增加mark 1:

`iptables -t mangle -I OUTPUT -p udp --dport 53 -j MARK --set-mark 1`

这样niptables会把本机数据重新路由到prerouting,可以代理本机.

## 配置规则

```bash
#!/bin/bash

# error break
set -e
# line-number for debug
set -x

lan_ipaddr="192.168.1.5"	# 局域网路由器IP地址
dns_port="5354"				# DNS转发服务端口
redir_port="7892"				# 透明代理转发端口
tproxy_port="7893"			# tproxy

# ip rule add fwmark 1 table 100
# ip route add local 0.0.0.0/0 dev lo table 100
clearAllRules() {
		# 这里是清除所有规则回到默认状态
		iptables-save | awk '/^[*]/ { print $1 } /^:[A-Z]+ [^-]/ { print $1 " ACCEPT" ; } /COMMIT/ { print $0; }' | iptables-restore
}
setProxy() {
		# 转发DNS请求到端口 dns_port 解析
		iptables -t nat -N CLASH_DNS
		iptables -t nat -F CLASH_DNS
		iptables -t nat -A CLASH_DNS -p udp -j REDIRECT --to-ports ${dns_port}
		iptables -t nat -A PREROUTING -p udp --dport 53 -j CLASH_DNS

		# tcp代理 redirect 实现
		iptables -t nat -N CLASH_TCP
		iptables -t nat -F CLASH_TCP
		iptables -t nat -A CLASH_TCP -d 0.0.0.0/8 -j RETURN
		iptables -t nat -A CLASH_TCP -d 10.0.0.0/8 -j RETURN
		iptables -t nat -A CLASH_TCP -d 127.0.0.0/8 -j RETURN
		iptables -t nat -A CLASH_TCP -d 169.254.0.0/16 -j RETURN
		iptables -t nat -A CLASH_TCP -d 172.16.0.0/12 -j RETURN
		iptables -t nat -A CLASH_TCP -d 192.168.0.0/16 -j RETURN
		iptables -t nat -A CLASH_TCP -d 224.0.0.0/4 -j RETURN
		iptables -t nat -A CLASH_TCP -d 240.0.0.0/4 -j RETURN
		iptables -t nat -A CLASH_TCP -p tcp -j REDIRECT --to-ports ${redir_port}
		iptables -t nat -A PREROUTING -p tcp -j CLASH_TCP

		# udp代理 tproxy实现
		iptables -t mangle -N CLASH_UDP
		iptables -t mangle -F CLASH_UDP
		iptables -t mangle -A CLASH_UDP -d 0.0.0.0/8 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 10.0.0.0/8 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 127.0.0.0/8 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 169.254.0.0/16 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 172.16.0.0/12 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 192.168.0.0/16 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 224.0.0.0/4 -j RETURN
		iptables -t mangle -A CLASH_UDP -d 240.0.0.0/4 -j RETURN
		iptables -t mangle -A CLASH_UDP -p udp --dport 53 -j RETURN
		iptables -t mangle -A CLASH_UDP -p udp -j TPROXY --on-port ${tproxy_port} --tproxy-mark 1
		iptables -t mangle -A PREROUTING -p udp -j CLASH_UDP # 应用规则
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

## 参考

[透明代理入门 | Project X](https://xtls.github.io/document/level-2/transparent_proxy/transparent_proxy.html#iptables-nftables)

[透明代理 UDP 为什么要用 TProxy？](https://www.jianshu.com/p/5393fb5e2c87)

[Clash旁路网关设置](https://blog.newhanly.com/2020/04/28/clash/)

[透明代理(TPROXY)](https://guide.v2fly.org/app/tproxy.html)
