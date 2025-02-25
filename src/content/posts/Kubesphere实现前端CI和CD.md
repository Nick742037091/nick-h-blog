---
title: KubeSphere实现前端CI和CD
published: 2025-02-23
description: '讲解KubeSphere实现前端项目CI/CD的流程'
image: '../../assets/images/articles/KubeSphere实现前端CI和CD/kubesphere.png'
tags: ['KubeSphere','Kubernetes','CI','CD']
category: '运维'
lang: 'zh_CN'
---

# 背景
在大型前端项目中，将应用部署到多台机器是一个常见的需求。这样做主要有以下几个原因：
1. 高可用性：当某台服务器出现故障时，其他服务器仍然可以正常提供服务。
2. 负载均衡：将用户请求分散到多台服务器上，提高系统整体的并发处理能力，优化用户访问体验。

使用Kubernetes（俗称k8s）对多台机器进行集群化管理是主流的选择，而KubeSphere是一款优秀的Kubernetes可视化平台。

本文选择在单台国内服务器上快速部署 Kubernetes v1.31.0 和 KubeSphere v4.1，并实现前端项目CI/CD的各个流程，适合快速入门。
参考[官方文档](https://www.kubesphere.io/zh/docs/v4.1/02-quickstart/01-install-kubesphere/)

# 准备服务器
:::tip
16G的云服务器很贵，年付的方式动辄几千块。如果是出于学习目的，推荐使用`腾讯云`的`竞价实例`，按量付费，价格极低，不使用时可以`关机不计费`😄。
:::

1. 公网IP是必须的
2. 推荐使用`16G内存`的服务器，否则安装KubeSphere可能会失败。
3. 安装Linux系统，我使用的是`Ubuntu`。
4. 使用root账号登录，这是必须的，否则有些流程会安装失败

:::warning
`腾讯云`默认创建主机名称是`VM-xxx`，存在大写字母，创建Kubernetes集群会失败，所以需要修改主机名称
1. 修改主机名称
```bash
sudo hostnamectl set-hostname 新主机名称
```
2. 编辑 /etc/hosts 文件以更新主机名映射
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/hostname-change.png)
3. 重启服务器
```
reboot
```
:::



# 创建Kubernetes 集群
## 设置下载区域
```bash
export KKZONE=cn
```
:::warning
设置变量只在当前登录账号生效，下面的`apt install`和`./kk create cluster`命令必须用root账号执行。

如果当前登录账号账号不是root账号，执行`sudo apt install`和`sudo ./kk create cluster`获取到的`KKZONE`环境变量就不是`cn`，安装速度就会很慢。
:::
## 安装KubeKey
```bash
# 会生成 KubeKey 二进制文件 kk
curl -sfL https://get-kk.kubesphere.io | sh -
```
## 安装依赖项
```bash
apt install socat conntrack -y
```
## 创建一个 Kubernetes 集群
```bash
./kk create cluster --with-local-storage  --with-kubernetes v1.31.0 --container-manager containerd  -y
```
:::tip
以上命令会使用内置的Docker运行时，所以主机不用预先安装Docker了
:::



# 安装 KubeSphere

## 安装Helm
参考[官网](https://helm.sh/zh/docs/intro/install/)，使用`Snap`进行安装：
```bash
snap install helm --classic
```

## 通过 helm 安装 KubeSphere 的核心组件
```bash
helm upgrade --install -n kubesphere-system --create-namespace ks-core https://charts.kubesphere.com.cn/main/ks-core-1.1.3.tgz --debug --wait   --set global.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks --set extension.imageRegistry=swr.cn-southwest-2.myhuaweicloud.com/ks
```
:::warning
以上命令设置了国内的源和镜像拉取地址，适合国内服务器使用
:::

安装完成后会出现以下提示，稍等一会之后，访问http://公网IP:30880 页面，默认账号：admin，默认密码：P@88w0rd 。
```bash
NOTES:
Thank you for choosing KubeSphere Helm Chart.

Please be patient and wait for several seconds for the KubeSphere deployment to complete.
...
```
如果访问不了，执行以下命令，如果存在pod的`STATUS`不是`Running`状态，就继续等待。
```bash
kubectl get pods -n kubesphere-system
```
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/install-status.png)



# 使用KubeSphere

## 关于集群
集群配置比较麻烦，这里直接使用已创建的host主集群，生产环境推荐创建一个新集群再使用。

## DevOps扩展
使用CI/CD功能依赖DevOps扩展，所以首先需要安装这个插件。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/extension-entry.png)
扩展中心搜索`Devops`，点击搜索结果。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/extension-search-devops.png)
点击`安装`，点击`下一步`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/extension-devops-add-1.png)
点击`开始安装`。安装完成之后，点击`下一步`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/extension-devops-add-2.png)
集群选择选择host集群，点击`下一步`，`确认`，弹窗会关闭，在后台安装`集群 Agent`。 


需要等待一段时间，可以在以下位置查看`集群 Agent`安装日志，安装完成这个这个三角形会消失。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/extension-devops-add-3.png)



## 企业空间
在首页点击`企业空间`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/workspace-entry.png)
再点击`创建`，输入`名称`：<i>fe-workspace</i>，点击`下一步`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/workspace-add-1.png)
可用集群选择host集群。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/workspace-add-2.png)
点击`确认`创建企业空间。

点击进入创建的`企业空间`页面，只需要关注`Devops项目`和`项目`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/workspace-home.png)


## 项目
项目相当于是一个命名空间，项目下可以创建应用，创建服务的时候可以同步创建关联的工作负载，工作负载就是前端构建产物的运行容器。
## 创建项目
在项目模块，点击`创建`，输入`名称`：<i>demo-project</i>，点击`确定`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/project-add.png)
点击进入创建的`项目`页面，点开`应用负载`菜单栏，只需要关注`服务`和`工作负载`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/project-home.png)

## 创建服务
在`企业空间`页面，点击`服务`->`创建`，我们要部署的前端项目构建物只是静态文件，所以选择`无状态服务`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-1.png)
输入服务`名称`：<i>demo-service</i>，`版本`保留默认值 <i>v1</i> 即可，点击`下一步`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-2.png)
将弹窗向上滚动，点击`添加容器`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-3.png)
容器组副本数量可以设置运行的容器数量，实现负载均衡。

运行服务需要选择镜像，但是我们的项目还没有构建镜像，这里先选一个nginx镜像用于跑负载，在后续的流水线中将镜像替换。
在镜像搜索框输入：`docker.1ms.run/nginx:alpine-perl`，回车搜索，在搜索结果列表中选择对应的版本，注意这里输入的是`国内镜像`，Dockerhub的镜像是找不到的。

`容器名称`输入：<i>demo-container</i>
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-4.png)

向下滚动到`可用配额`，可以根据实际情况设置分配的资源，这里不做限制。

点击`使用默认镜像端口`，会自动填入容器的nginx端口和容器对外暴露端口，都是80端口，后续我们配置构建镜像端口要保持一致。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-5.png)
点击`下一步`，进入`存储设置`，这里无需修改，点击`下一步`。

勾选外部访问，选择访问模式为NodePort,将为对外暴露一个可以通过`公网ip`访问的`服务端口`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-add-6.png)
点击`创建`。

点击`服务`模块，可以看到创建的服务对外暴露的端口
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/service-new.png)
此时可以通过`http://公网ip:服务外部访问端口`访问页面了，可以看到nginx信息页。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/page-nginx.png)
点击`工作负载`模块，注意到创建的负载名称是`demo-service-v1`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/deployment-new.png)


## 创建Devops
在`企业空间`页面，点击`Devops`->`创建`，输入`名称`：<i>demo-devops</i>，点击`确定`。
点击进入创建的`Devops`页面，只需要关注`凭证`、`代码仓库`和`流水线`。

### 凭证

#### 配置kubeconfig凭证
`kubeconfig凭证`用于为集群执行`kubectl`命令提供凭证，添加方式
1. 点击`凭证`->`创建`
2. `类型`选择`kubeconfig`，`内容`会自动填充，不用修改
3. `名称`输入：kubeconfig
4. 点击`确定`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/kubeconfig-certificate.png)


#### 配置镜像仓库凭证
添加镜像仓库凭证，为登录镜像仓库平台提供用户名和密码
1. 点击`凭证`->`创建`
2.`类型`选择`用户名和密码`，
3.`名称`输入：harbor
4. 输入镜像仓库的`用户名`和`密码`
5. 点击`确定`
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/harbor-certificate.png)

### 创建前端项目
使用`npm create vite`创建一个`vue`项目，添加构建所属配置文件，并提交到git仓库中，为了方便访问，这里选择提交到gitee并设置并设置的公开项目。可以参考这个[gitee项目](https://gitee.com/qq742037091/k8s-demo)

`deploy`目录为构建配置文件，包含三个文件
#### Jenkinsfile文件
执行jenkins流水线的声明文件，在构建镜像使用到了Dockefile文件
```bash
pipeline {
  agent {
    kubernetes {
      // 继承KubeSphere自带的nodejs容器
      inheritFrom 'nodejs base'
      containerTemplate {
        // 容器名称，提供给下面的stage使用
        name 'nodejs'
        // 使用国内可以访问的镜像指定nodejs版本
        image 'docker.1ms.run/node:18-alpine'
      }
    }
  }

  // 环境变量
  environment {
    // 镜像仓库域名，不可删除
    REGISTRY = 'harbor.nick-h.cn'
    // 镜像仓库名称，不可删除
    DOCKERHUB_NAMESPACE = 'qq742037091'
    // 镜像应用名称，不可删除
    APP_NAME = 'demo'
    // 使用环境变量组装镜像名称，BUILD_NUMBER为流水线编号
    DOCKER_IMAGE = "${REGISTRY}/${DOCKERHUB_NAMESPACE}/${APP_NAME}:snapshot-${BUILD_NUMBER}"
    // 项目名称
    DEPLOYMENT_NAMESPACE = 'demo-project'
    // 工作负载名称
    DEPLOYMENT_NAME = 'demo-service-v1'
    // 容器名称
    CONTAINER_NAME = 'demo-container'
  }

  stages {
    // 拉取代码
    stage('Clone repository') {
      steps {
          checkout(scm)
      }
    }

    // 安装依赖
    stage('Run npm install') {
      steps {
        // 使用agent中定义的的nodejs容器
        container('nodejs') {
          // 使用国内npm源，加速安装
          sh 'npm config set registry https://registry.npmmirror.com'
          sh 'npm install'
        }

      }
    }

    // 生产构建文件
    stage('Run npm build') {
      steps {
        // 使用agent中定义的的nodejs容器
        container('nodejs') {
          sh 'npm run build'
        }
      }
    }

    // 构建镜像并推送到镜像参考
    stage('Run docker build') {
      agent none
      steps {
        // 使用kubesphere自带的base镜像，可以执行docker命令
        container('base') {
          sh 'docker build -f /deploy/Dockerfile -t $DOCKER_IMAGE .'
          // 使用私有的镜像仓库凭证，名称：harbor
          withCredentials([usernamePassword(credentialsId: 'harbor', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
            // 登录镜像仓库
            sh 'echo "$DOCKER_PASSWORD"|docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin'
            // 推送镜像
            sh 'docker push $DOCKER_IMAGE'
          }
        }
      }
    }

    // 部署到Kubernetes
    stage('Deploy to Kubernetes') {
        steps {
            script {
                // 使用配置好的Kubernetes凭证，名称：kubeconfig
                withCredentials([kubeconfigFile(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                  // 使用kubesphere自带的base镜像，可以执行kubectl命令
                  container('base') {
                    // 使用kubectl命令，更新工作负载镜像名称，注意这里每次构建的镜像名称都不一样
                    sh """
                      kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${DOCKER_IMAGE} -n ${DEPLOYMENT_NAMESPACE}
                    """
                    // 获取部署结果
                    sh """
                      kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${DEPLOYMENT_NAMESPACE}
                    """
                  }
                }
            }
        }
    }
  }
}
```

#### Dockefile文件
构建镜像的配置文件，使用到`nignx配置文件`
```bash
# 拉取国内的nginx镜像
FROM docker.1ms.run/nginx:alpine-perl
# 暴露80端口
EXPOSE 80
# 复制构建文件到nginx http根目录
COPY ./dist /usr/share/nginx/html
# 删除默认nginx配置
RUN rm /etc/nginx/conf.d/default.conf
# 复制自定义nginx配置
COPY ./deploy/nginx.conf /etc/nginx/conf.d/
```

### ningx.conf 文件
容器内nginx的配置文件，会替换掉默认的配置文件
```bash
server {
    listen       80; # 监听80端口
    server_name  localhost; # 匹配localhost域名

    root /usr/share/nginx/html;  # 设置ningx http根目录，如果前端项目设置了baseUrl，需要在路径后面补充
    index index.html index.htm;  # 设置访问路径最后的index.html/index.htm可缺省

    location / {
        # 设置html文件不缓存
        if ($request_filename ~ .*.(html|htm)$) {
          expires -1s;
        }
        # 设置js、css、图片、字体缓存30天
        if ($request_filename ~ .*.(js|css|jpe?g|png|gif)$) {
          expires 30d;
        }
        try_files $uri $uri/ =404;  # 未匹配到文件，跳转到404文件
    }
}

```

### 添加代码仓库
点击`代码仓库`->`创建`，输入`名称`：<i>demo-repo</i>
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/repo-add-1.png)
点击`选择代码仓库`，切换`git`页签
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/repo-add-2.png)
输入git仓库地址，由于使用的是公开仓库，不用输入凭证。点击√号，再点击`确定`，完成添加。


### 添加流水线
点击`代码仓库`->`创建`，输入`名称`：<i>demo-pipeline</i>，流水线类型选择`多分支流水线`，再选择已添加的`代码仓库`，点击下一步。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/pipeline-add-1.png)
勾选`正则过滤`，设定构建流水线绑定的git分支。

`脚本路径`设置为：<i>deploy/Jenkinsfile</i>。

勾选`扫描触发器`，根据需要选择`定时扫描间隔`，在检查到git分支有更新时`自动运行流水线`。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/pipeline-add-2.png)

点击`创建`。

![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/pipeline-running.png)
如果配置没问题，流水线已经跑起来了。如果没有跑起来可以查看扫描日志。

### 查看流水线日志
点击`运行中`的流水线，查看运行日志。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/pipeline-success.png)

如果流水线运行`成功`，访问`http://公网ip:服务外部访问端口`。

可以看到页面已经更新为前端项目首页了🎉🎉🎉。
![alt text](../../assets/images/articles/KubeSphere实现前端CI和CD/page-home.png)

