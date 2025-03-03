---
title: 轻量级异常监控平台GlitchTip
published: 2025-03-02
description: 'Senry的轻量级平替'
image: '../../assets/images/articles/轻量级异常监控平台GlitchTip/glitchtip.png'
tags: ['监控','glitchtip']
category: '前端'
lang: 'zh_CN'
---

[Setnry](https://sentry.io/)是广泛使用的开源异常监控平台，功能很强大，但是占用资源太多，基本上服务器没有16G内存是运行不了的。[GlitchTip](https://glitchtip.com/)是一款轻量级的开源异常监控平台，可以直接使用Sentry的SDK，但是占用资源非常低。



# 资源消耗对比
[Setnry](https://sentry.io/) 和[GlitchTip](https://glitchtip.com/)都支持私有化部署，先看一下各自的资源消耗

## 最低配置要求


| 平台       | CPU  | 内存  | 存储  |
|------------|------|-------|-------|
| Sentry     | 4核  | 16GB😞  | 20GB |
| GlitchTip  | 1核  | 512MB👍   | 30GB  |

存储空间要求都不高，Sentry这套CPU和内存要求，一般服务器还真的跑不起来；而GlitchTip对CPU和内存要求极低，最低配的服务器就够用了。

# 安装GlitchTip
推荐使用Docker Compose安装，一行命令就ok了。
## 前置条件
* 安装[Docker Compose](https://docs.docker.com/compose/)
* 配置docker镜像加速器

linux系统docker配置文件： `/etc/docker/daemon.json`
```json
{
  "registry-mirrors": [
    "https://docker.1ms.run"
  ]
}
```
## 安装步骤
### 下载docker compose配置文件
```bash
wget https://glitchtip.com/assets/docker-compose.sample.yml
```

### 修改配置文件名称
`docker-compose.sample.yml` -> `docker-compose.yml`

### 调整配置文件内容
根据需要调整配置文件，以下为推荐修改的内容
#### SECRET_KEY
使用`openssl rand -hex 32`生成的字符串替换掉原来的内容
#### EMAIL_URL
设置用来发送通知的邮件，格式为`smtp://email:password@smtp_url:port`。

如果使用`QQ邮箱`，必须使用`smtps协议`，用[授权码](https://wx.mail.qq.com/list/readtemplate?name=app_intro.html#/agreement/authorizationCode)代替密码，smtp_url为`smtp.qq.com`，端口号为`587`。以下为示例：

```yml
x-environment: &default-environment
  EMAIL_URL: smtps://qq邮箱:授权码@smtp.qq.com:587
```

#### 端口号
默认端口号为容器内8000，对外保留8000。假设想对外保留9000端口号，配置如下
```yml
services:  
  web:    
    ports: 
      - "9000:8000"
```

:::warning
不要调整 x-environment 的 PORT
:::



### 执行安装命令
```bash
docker compose up -d
```
看到以下信息说明安装成功🎉
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/install.png)
可以使用`http://公网ip:配置的端口`访问，推荐还是使用域名访问，用nginx进行转发。



# 使用GlitchTip
## 注册账号
在登录页面点击`Sign up`，注册账号
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/login.png)


## 创建一个新组织
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/create-organization.png)

## 创建一个新项目
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/create-project.png)
选择项目使用的框架，这里以`Vue`为例，首次创建项目需要先创建一个团队
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/create-team.png)

## 嵌入SDK
在`Projects`-`Settings`中可以查看项目的配置
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/project-setting-1.png)

[GlitchTip](https://glitchtip.com/)使用的是[Sentry的SDK](https://docs.sentry.io/platforms/javascript/), 以下为`Vue3`的接入示例，集体可以参考[Sentry官网](https://docs.sentry.io/platforms/javascript/guides/vue/)
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/project-setting-2.png)

安装`@sentry/vue`依赖
```bash
npm install @sentry/vue
```
嵌入SDK
```js
import { createApp } from "vue";
import { createRouter } from "vue-router";
import * as Sentry from "@sentry/vue";
const app = createApp({
  // ...
});
const router = createRouter({
  // ...
});

Sentry.init({
  app,
  dsn: "替换成项目的dsn",
  integrations: [
    // 添加路由追踪
    Sentry.browserTracingIntegration({ router }),
  ],
});
```

## 上传构建产物和sourcemap
生产环境的代码都是进过压缩和混淆编译的，所以需要上传构建产物和sourcemap到GlitchTip后台，才能在监控到异常时定位到源码。

这里以使用`Vite`为例，其他可以参考[Sentry官网](https://docs.sentry.io/platforms/javascript/sourcemaps/)

## 创建Auth Tokens
创建`Auth Tokens`以支持上传代码
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/auth-token-1.png)
权限至少需要勾选`project:releases`
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/auth-token-2.png)

## 安装依赖
```bash
npm install @sentry/vite-plugin -D
```
## 添加插件
在`vite.config.ts`中添加插件

```ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { sentryVitePlugin } from "@sentry/vite-plugin";

export default defineConfig({
  build: {
    sourcemap: true,
  },
  plugins: [
    vue(),
    sentryVitePlugin({
      url: '替换成glitchtip的地址',
      org: "替换成组织名称",
      project: "替换成项目名称",
      authToken: '替换成Auth Tokens',
      sourcemaps: {
        // 指定构建产物位置
        assets: 'dist/assets/*.js',
        // 推送构建产物之后删除sourcemap，避免在生产环境中暴露
        filesToDeleteAfterUpload: 'dist/assets/*.js.map',
      },
    }),
  ],
})
```

## 验证异常监控
1.在某个点击事件中抛出异常，执行`npm run build`，构建产物和sourcemap上传到GlitchTip后台。
2.将代码部署到服务器上或者在本地执行`serve ./dist`，访问页面，点击按钮，抛出异常。
3.在GlitchTip后台查看异常
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/Issues-1.png)
4.可查看到异常，并且正确定位到源码位置
![alt text](../../assets/images/articles/轻量级异常监控平台GlitchTip/issues-2.png)



