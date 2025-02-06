---
title: webpack5升级rspack
published: 2025-02-01
description: '将webpack5的vue项目升级至rspack'
image: '../../assets/images/articles/webpack5升级rspack/rspack.png'
tags: ['rspack','webpack5','webpack']
category: '前端'
lang: 'zh_CN'
---


# 前置知识点
## rspack
* 基于 Rust 编写的高性能 JavaScript 打包工具
* HMR超快、开发冷启动快、生产构建速度也快（没错build也快）
* 兼容大部分 webpack api，非常适用于webpack项目的迁移

## swc-loader
* 内置swc-loader，基于Rust实现
* swc支持高版本ES和Typescript语法，无需额外的babel与ts解析器

## 准备
* Node.js >= 16 
* 必须先升级至Webpack5




# 主要参考
1. [迁移 webpack](https://rspack.org/zh/guide/migration/webpack)
2. [vue2项目](https://rspack.org/zh/guide/tech/vue#vue-2)
3. 示例: [vue2-ts](https://github.com/rspack-contrib/rspack-examples/tree/main/rspack/vue2-ts)


:::tip
本项目安装的vue-loader版本是15.10.1，不依赖于webpack。<span style="color:red">部分版本无法脱离webpack</span>。
:::

:::tip
实际项目会区分不同的环境，可以通过`rspack build --env xx=xxx`添加环境变量，并在配置里面获取。
具体参考：[导出配置函数](https://rspack.org/zh/config/index#%E5%AF%BC%E5%87%BA%E9%85%8D%E7%BD%AE%E5%87%BD%E6%95%B0)
:::

# 迁移前后对比

运行机器：MBP2020/M1/16G

| 时间  |  webpack5  |  rspack  |     提升   | 
|------|----------|---------| ---------|
| 开发冷启动时间 | 22.66s 🐢| 9.34s 🚗  | <span style="color:orange">↓58%</span> |
| HMR时间 | 3.15s 🐢 | 0.37s 🚀| <span style="color:red">↓88%</span> |
| 生产构建时间 | 55.43s 🐢 | 6.39s 🚀| <span style="color:red">↓88%</span> |
 
## 总结
可以看到，rspack相比webpack，HMR和生产构建效率都有大幅提升。开发冷启动效率虽然没有vite那么惊艳，但是已经比webpack快很多了，并且是在可以接受的范围内了。
