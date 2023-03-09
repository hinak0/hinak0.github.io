---
title: "git进行网站备份"
date: "2022-03-12"
categories:
  - "web"
---

## 构想

wordpress的数据分成两个部分：网站目录和sql数据库，将这两个部分定时打包并push到gitee

#### 打包网站目录

```
tar -cvf /home/chlen/my-services/backup/my-blog.tar /var/lib/docker/volumes/eaaf8ee23fdec167e4599903a297ce3fe9c102c0624f063490b1f72d769a5069
```

#### 打包数据库

```
/usr/bin/mysqldump -u用户名 -p 数据库名 > /home/chlen/my-services/backup/blog-sql.sql
```

#### 编写自动脚本打包并上传

注意备份数据库时需要手动输入密码，为了能执行自动化而不必输入密码，使用pump代替dump,配置方法如下：

```
mysql_config_editor  set --login-path=key --host=localhost --user=root --password
# 这里要手动输入密码来生成密钥
```

完整的sh脚本

```
#!/bin/sh
cd $(cd `dirname $0`;pwd)

# 备份数据库
mysqlpump --login-path=key 数据库名字 > /home/chlen/my-services/backup/blog-sql.sql

# 备份网页目录
tar -cvf /home/chlen/my-services/backup/my-blog.tar /var/lib/docker/volumes/eaaf8ee23fdec167e4599903a297ce3fe9c102c0624f063490b1f72d769a5069

# 同步到git

git commit -am autosync

git push
```

#### 部署自动任务

使用root用户来防止没有权限；

考虑到可能的更新频率，设置3天同步一次；

```
crontab -e；
0 4 * * 1,4 sh /home/chlen/my-services/dev/sync.sh
# 实际是周三，周六各一次
```

## 后记

原本打算同步整个docker容器镜像，打包后发现有600m，遂放弃；

（注：docker wordpress博客资源默认存储在数据卷中，所以打包容器是木大的）

又及，mysql的配置文件太多：

![](images/屏幕截图-2022-03-12-151537.png)
