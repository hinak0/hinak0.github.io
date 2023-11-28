---
title: windows开启ipv6外部访问
date: 2022-09-07
categories:
  - 通信網
---

## ipv6特点

- 使用64位为网络号，64位为主机号替代ipv4的子网掩码+可变网络标识设计。
- 全球分配ip时，前48位为全球路由前缀分配给组织，目前已经分配的全球路由前缀的前3bit均为001（以2000::/3打头），剩下的16位用于组织构建子网

## 临时ipv6地址

临时地址的地址是随机生成的，主要作用是对外通讯使用，他最大的优点就是没有暴露本机mac地址。因为linux和mac系统在默认下是使用EUI-64来生成IPv6地址，而windows是默认随机生成（其实都可以改）

## EUI-64

IEEE定义的一种从48位mac地址转化为64位ipv6主机id的规范

具体做法为：

- 在mac中间插入`FFFE`
- 第一个字节的第七位取反

正因为上面的性质，ipv6地址可能暴露mac地址，windows访问外部使用随机生成的id避免暴露mac地址。

### 如何关闭临时ipv6地址

[https://www.cnblogs.com/LandWind/p/ipv6-disable-enable.html](https://www.cnblogs.com/LandWind/p/ipv6-disable-enable.html)

## 修改跃点数实现ipv6优先使用

![](images/ed9f36.png)

windows不修改ipv6优先的话，有可能访问外部时，一直使用ipv4地址。

## python ipv6 socket server demo

```python
import socket

mySocket = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
host = ''
port = 80
mySocket.bind((host, port))
mySocket.listen(10)
print("开始监听")
while True:
	client, address = mySocket.accept()
	data = client.recv(1024)
	print(data.decode("utf-8"))
	# client.send("Here's Johnny!".encode("utf-8"))
	client.send("""HTTP/1.1 302 Moved Temporarily
Server: bfe/1.0.8.18
Date: Wed, 07 Sep 2022 09:04:11 GMT
Content-Type: text/html
Connection: close
Location: https://baidu.com""".encode("utf-8"))
	client.close()
```

## 想法

ipv4下，想获得公网ip是比较麻烦的，互联网在我看来，更像一种经过多层NAT更像一种只能向上的树结构。

ipv6下互联网真的变成一张网了，任意两个设备都可以连接（然而阿里云不给我分配ipv6，令人感叹）。
