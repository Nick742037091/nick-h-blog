---
title: 面试题-Vue篇
published: 2025-03-11
description: 'Vue面试题'
image: '../../assets/images/articles/面试题-Vue篇/vuejs.jpg'
tags: ['vue','面试']
category: '前端'
lang: 'zh_CN'
---


本文仅面试参考，不做深入讲解。

# Vue的响应式原理
可以从三个方面来回答：

## 数据劫持
`Vue2`使用`Object.defineProperty`来劫持对象，`Vue3`使用`Proxy`来劫持对象。
`Proxy`和`Oject.defineProperty`相比，可以实现更全面的响应式处理：
1. 都可以拦截`获取属性值`和`设置属性值`这两个操作。
2. `Proxy`支持拦截`动态属性`，包括`添加属性`和`删除属性`两个操作，`Oject.defineProperty`不可以，数组的`索引`本质上属性动态属性，因为数组通过`索引`赋值也没法被`Oject.defineProperty`拦截到。
3. `Proxy`可以直接劫持整个对象，而`Object.defineProperty`只能劫持对象的单个属性，如果需要整个对象实现响应式，就需要遍历对象的每个属性，并使用`Object.defineProperty`进行劫持。

`Vue2`和`Vue3`依赖收集和视图更新的实现方式本质上是一样的，以下以`Vue3`为例进行说明：

## 依赖收集
在模板编译过程中，当访问到数据对象的属性时，会触发`Proxy`的`get拦截函数`，将当前活跃的watcher(视图更新函数)与数据属性进行关联，实现依赖收集。

## 视图更新
当数据属性发生变化时，会触发`Proxy`的`set拦截函数`，通知所有与该属性关联的watcher执行对应的视图更新操作。

