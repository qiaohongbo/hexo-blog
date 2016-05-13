---
title: 用 docker 运行 shadowsocks
date: 2016-05-13 11:16:36
tags:
  - docker
  - shadowsocks
categories:
  - docker
---

## 安装 Docker

安装 Docker 官方的最新发行版
```
curl -sSL https://get.daocloud.io/docker | sh
```

安装过程结束后，可执行下面命令验证安装结果。如果看到输出 `docker start/running` 就表示安装成功。
```
sudo service docker status
```

## 安装 docker-shadowsocks

### 克隆
```
git clone https://github.com/bitqiu/docker-shadowsocks.git
```

### 打包
```
cd docker-shadowsocks
docker build -t bitqiu/shadowsocks .
```

### 运行
```
docker run -d -p 8388:8388 bitqiu/shadowsocks -s 0.0.0.0 -k $PASSWORD
```