---
title: http代理与https代理
date: 2023-03-09 22:26:38
categories:
  - "网络工程"
tags:
---

## https代理工作流程
- client发送一个[http connect](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/CONNECT) 到 proxy , 告诉自己要访问的域名与端口
- proxy server 进行dns解析，创建与目标的通道，随后告诉client连接成功`Connection Established`，也就是隧道（tunnel）创建完成。
- 随后客户端通过这个隧道进行与目标的tls握手，进行加密通讯。
#### 有几个重点
- proxy 进行dns解析
- 连接是加密的，对于proxy server，它也没办法获取通讯内容
## http代理工作流程
相当于将所有域名绑定到代理服务器地址，由代理获取response后返回client

## 代码示例

- 使用python实现一个http and https 代理。
- 使用多线程来避免阻塞

参考见文末
```python
import select
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from urllib.parse import urlparse


class RequestHandler(BaseHTTPRequestHandler):

	def _recv_data_from_remote(self, sock):
		data = b''
		while True:
			recv_data = sock.recv(4096)
			if not recv_data:
				break
			data += recv_data
		sock.close()
		return data

	def send_data(self, sock, data):
		# print(data)
		bytes_sent = 0
		while True:
			r = sock.send(data[bytes_sent:])
			if r < 0:
				return r
			bytes_sent += r
			if bytes_sent == len(data):
				return bytes_sent

	def handle_tcp(self, sock, remote):
		# 处理 client socket 和 remote socket 的数据流
		try:
			fdset = [sock, remote]
			while True:
				# 用 IO 多路复用 select 监听套接字是否有数据流
				r, w, e = select.select(fdset, [], [])
				if sock in r:
					try:
						data = sock.recv(4096)
						if len(data) <= 0:
							break
						result = self.send_data(remote, data)
						if result < len(data):
							raise Exception('failed to send all data')
					except:
						pass

				if remote in r:
					try:
						data = remote.recv(4096)
						if len(data) <= 0:
							break
						result = self.send_data(sock, data)
						if result < len(data):
							raise Exception('failed to send all data')
					except:
						pass
		except Exception as e:
			raise (e)
		finally:
			sock.close()
			remote.close()

	def do_CONNECT(self):
		self.log_message(f"CONNECT {self.path}")

		uri = self.path.split(":")
		host, port = uri[0], int(uri[1])
		host_ip = socket.gethostbyname(host)

		remote_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		remote_sock.connect((host_ip, port))
		# 告诉客户端 CONNECT 成功
		self.wfile.write(
		    "{protocol_version} 200 Connection Established\r\n\r\n".format(protocol_version=self.protocol_version
		                                                                   ).encode()
		)

		# 转发请求
		self.handle_tcp(self.connection, remote_sock)

	# http proxy

	def do_http(self, method: str):
		self.log_message(f"{method} {self.path}")
		uri = urlparse(self.path)
		host, path = uri.hostname, uri.path
		host_ip = socket.gethostbyname(host)
		port = uri.port or 80

		# 为了简单起见，Connection 都为 close, 也就不需要 Proxy-Connection 判断了
		del self.headers['Proxy-Connection']
		self.headers['Connection'] = 'close'

		# 构造新的 http 请求
		send_data = "{method} {path} {protocol_version}\r\n".format(
		    method=method, path=path, protocol_version=self.protocol_version
		)
		headers = ''
		for key, value in self.headers.items():
			headers += "{key}: {value}\r\n".format(key=key, value=value)
		headers += '\r\n'
		send_data += headers

		sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.connect((host_ip, port))
		# 发送请求到目标地址
		sock.sendall(send_data.encode())
		try:
			data = self._recv_data_from_remote(sock)
			self.wfile.write(data)
		except:
			self.wfile.write(b"EOF")

	def do_GET(self):
		self.do_http("GET")

	def do_HEAD(self):
		self.do_http("HEAD")

	def do_POST(self):
		self.do_http("POST")


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
	pass


if __name__ == '__main__':
	server = ThreadedHTTPServer(('', 8080), RequestHandler)
	server.serve_forever()
```

## 参考
[socket-example](https://github.com/facert/socket-example)
