---
title: 安装 shadowsocks-go 多用户版
date: 2016-04-29 09:18:33
categories:
    - server
tags:
    - shadowsocks
---

## 安装 git

```
# Remove packaged Git
sudo apt-get remove git-core

# Install dependencies
sudo apt-get install -y libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev build-essential

# Download and compile from source
cd /tmp
curl -O --progress https://www.kernel.org/pub/software/scm/git/git-2.7.4.tar.gz
echo '7104c4f5d948a75b499a954524cb281fe30c6649d8abe20982936f75ec1f275b  git-2.7.4.tar.gz' | shasum -a256 -c - && tar -xzf git-2.7.4.tar.gz
cd git-2.7.4/
./configure
make prefix=/usr/local all

# Install into /usr/local/bin
sudo make prefix=/usr/local install
```

## 安装 golang

```
curl -O --progress https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz
echo '43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53  go1.5.3.linux-amd64.tar.gz' | shasum -a256 -c - && \
  sudo tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz
sudo ln -sf /usr/local/go/bin/{go,godoc,gofmt} /usr/local/bin/
rm go1.5.3.linux-amd64.tar.gz
export GOPATH=~/.go
```

## 安装 redis-server

```shell
# ubuntu
apt-get install redis-server
# centos
yum install redis-server
```

## 安装 ss 多用户版

```
go get github.com/orvice/shadowsocks-go
cd ~/.go/src/github.com/orvice/shadowsocks-go/mu
go get
go build
```

拷贝 `example.conf` 到  `~/.go/bin/`

```
cp example.conf ~/.go/bin/config.conf
cd ~/.go/bin/
./mu -debug
```
这里应该会报错，因为还没跟前端连接起来。不用理会


## 使用 supervisor 保持 ss 多用户版 服务端运行

安装 supervisor :
```
apt-get install supervisor
```
新建 supervisor 配置文件
`vi /etc/supervisor/conf.d/ssserver.conf`
```
[program:ssserver]
command = /root/.go/bin/mu
directory = /root/.go/bin/
user = root
autostart = true
autorestart = true
stdout_logfile = /var/log/supervisor/ssserver.log
stderr_logfile = /var/log/supervisor/ssserver_err.log
```
重载 supervisor
```
supervisorctl reload
```
