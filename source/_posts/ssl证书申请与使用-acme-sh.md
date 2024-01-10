---
title: ssl证书申请与使用-acme.sh
categories:
  - Linux运维
date: 2023-10-10 21:01:21
tags:
cover:
---

## Before

今天域名备案流程终于走完了，每次重新开服务器就要重新备案(它生怕我伤害民族感情，我真的哭死)，申请证书，很麻烦，这里就记录一下zero_ssl的免费证书申请流程吧,以后再要搞照着来就行。

## Steps

### setup

```bash
curl https://get.acme.sh | bash

# auto update (optional)
acme.sh --upgrade --auto-upgrade

acme.sh --set-default-ca --server zerossl

acme.sh --register-account -m hinak0@qq.com --server zerossl
```

##### cloudfare

```bash
export CF_Key="<yourkey>"
export CF_Email="hinak0@qq.com"

acme.sh --issue --dns dns_cf -d hinak0.site -d "*.hinak0.site"
```

##### nginx

```bash
# auth by nginx
# 记得打开端口防火墙
acme.sh --issue -d hinak0.site -d "*.hinak0.site" --nginx
```

##### http-server

```bash
# 确保80端口空闲
acme.sh --issue -d hinak0.site -d "*.hinak0.site"
```

### install cert

```bash
acme.sh --installcert -d hinak0.site -d "*.hinak0.site" --fullchain-file /usr/local/ssl/hinak0.site.cer --key-file /usr/local/ssl/hinak0.site.key
```

最后在nginx加载证书

```conf
server {
  listen 443 ssl;
  server_name hinak0.site;

  ssl_certificate /usr/local/ssl/hinak0.site.cer;
  ssl_certificate_key /usr/local/ssl/hinak0.site.key;

  ssl_session_timeout 5m;
  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;

  location / {
    root /var/www/html/hinak0.github.io;
    index index.html;
  }
}
server {
  listen 80;
  server_name hinak0.site;
  return 301 https://hinak0.site;
}
```

### update cert

```bash
# 记得保持80端口空闲，关掉nginx的80端口301重定向
acme.sh --renew -d hinak0.site -d "*.hinak0.site" --force

acme.sh --installcert -d hinak0.site -d "*.hinak0.site" --fullchain-file /usr/local/ssl/hinak0.site.cer --key-file /usr/local/ssl/hinak0.site.key
```
