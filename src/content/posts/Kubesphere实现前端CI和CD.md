---
title: Kubesphere实现前端CI和CD
published: 2025-02-23
description: '讲解Kubesphere实现前端项目CI/CD的流程'
image: '../../assets/images/articles/Kubesphere实现前端CI和CD/kubesphere.png'
tags: ['Kubesphere','Kubernetes','CI','CD']
category: '运维'
lang: 'zh_CN'
---

# 背景
在大型前端项目中，将应用部署到多台机器是一个常见的需求。这样做主要有以下几个原因：
1. 高可用性：当某台服务器出现故障时，其他服务器仍然可以正常提供服务。
2. 负载均衡：将用户请求分散到多台服务器上，提高系统整体的并发处理能力，优化用户访问体验。

使用Kubernetes（俗称k8s）对多台机器进行集群化管理是主流的选择，而Kubesphere是一款优秀的Kubernetes可视化平台。

本文将讲解使用Kubesphere实现前端项目CI/CD的各个流程，适合快速入门。


# 搭建Kubesphere服务
本文选择在单台国内服务器上快速部署 Kubernetes v1.31.0 和 KubeSphere v4.1，参考[官方文档](https://www.kubesphere.io/zh/docs/v4.1/02-quickstart/01-install-kubesphere/)

## 准备服务器
1. 公网IP是必须得
2. 推荐使用`16G内存`的服务器，否则安装Kubesphere可能会失败。
3. 安装Linux系统，我使用的是`Ubuntu`。
:::tip
16G的云服务器很贵，年付的方式动辄几千块。如果是出于学习目的，推荐使用`腾讯云`的`竞价实例`，按量付费，价格极低，不使用时可以`关机不计费`😄。
:::


## 创建Kubernetes 集群
### 设置下载区域
```bash
export KKZONE=cn
```
### 安装KubeKey
```bash
# 会生成 KubeKey 二进制文件 kk
curl -sfL https://get-kk.kubesphere.io | sh -
```
### 安装依赖项
```bash
apt install socat conntrack -y
```
### 创建一个 Kubernetes 集群
```bash
./kk create cluster --with-local-storage  --with-kubernetes v1.31.0 --container-manager containerd  -y
```
:::tip
以上命令会使用内置的Docker运行时，所以主机不用预先安装Docker了
:::



## 安装 KubeSphere

### 安装Helm
参考[官网](https://helm.sh/zh/docs/intro/install/)，使用`Snap`进行安装：
```bash
sudo snap install helm --classic
```

### 通过 helm 安装 KubeSphere 的核心组件
```bash
helm upgrade --install -n kubesphere-system --create-namespace ks-core https://charts.kubesphere.com.cn/main/ks-core-1.1.3.tgz --debug --wait   --set global.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks --set extension.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks
```
:::warning
以上命令设置了国内的源和镜像拉取地址，适合国内服务器使用
:::

安装完成后，输出信息会显示 KubeSphere Web 控制台的 IP 地址和端口号，默认的 NodePort 是 30880，使用http://公网IP:30880 访问页面。
```bash
NOTES:
Thank you for choosing KubeSphere Helm Chart.

Please be patient and wait for several seconds for the KubeSphere deployment to complete.

1. Wait for Deployment Completion

    Confirm that all KubeSphere components are running by executing the following command:

    kubectl get pods -n kubesphere-system

2. Access the KubeSphere Console

    Once the deployment is complete, you can access the KubeSphere console using the following URL:

    http://192.168.6.10:30880

3. Login to KubeSphere Console

    Use the following credentials to log in:

    Account: admin
    Password: P@88w0rd

NOTE: It is highly recommended to change the default password immediately after the first login.

For additional information and details, please visit https://kubesphere.io.
```



