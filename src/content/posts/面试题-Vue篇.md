---
title: 面试题-Vue篇
published: 2025-03-11
description: 'Vue面试题'
image: '../../assets/images/articles/面试题-Vue篇/vuejs.jpg'
tags: ['vue','面试']
category: '前端'
lang: 'zh_CN'
---


本文收集常见前端面试题，仅供面试复习使用。

# Vue的响应式原理
可以从三个方面来回答：

## 数据劫持
`Vue2`使用`Object.defineProperty`来劫持对象，`Vue3`使用`Proxy`来劫持对象。
`Proxy`和`Oject.defineProperty`相比，可以实现更全面的响应式处理：
1. 都可以拦截`获取属性值`和`设置属性值`这两个操作。
2. `Proxy`支持拦截`动态属性`，包括`添加属性`和`删除属性`两个操作，`Oject.defineProperty`不可以，数组的`索引`本质上属于动态属性，因此数组通过`索引`赋值也没法被`Oject.defineProperty`拦截到。
3. `Proxy`可以拦截函数，`Object.defineProperty`不可以，需要通过重写实现数组函数拦截功能。
4. `Proxy`可以直接劫持整个对象，而`Object.defineProperty`只能劫持对象的单个属性，如果需要整个对象实现响应式，就需要遍历对象的每个属性，并使用`Object.defineProperty`进行劫持。

`Vue2`和`Vue3`依赖收集和视图更新的实现方式本质上是一样的，以下以`Vue3`为例进行说明：

## 依赖收集
在模板编译过程中，当访问到数据对象的属性时，会触发`Proxy`的`get拦截函数`，将当前活跃的watcher(视图更新函数)与数据属性进行关联，实现依赖收集。

## 视图更新
当数据属性发生变化时，会触发`Proxy`的`set拦截函数`，通知所有与该属性关联的watcher执行对应的视图更新操作。

# BFC

## 什么是BFC

BFC指的是块级格式化上下文，可用于修复以下问题：

1. 浮动布局导致的父元素高度塌陷
2. 父子元素的margin塌陷
3. 兄弟元素的margin合并

## 如何创建BFC

1. html元素
2. 浮动元素
3. position设置为absolute/fixed
4. display设置为flex/grid/inline-block/inline-flex/inline-grid
5. overflow设置为hidden/auto/scroll

# 防抖和节流

## 防抖
在设定时间内再次调用触发，会重新计时，在计时时间结束之后执行函数。

### 实现
```ts
/**
* fn: 执行函数
* timerout: 定时时间
* flag：是否立即执行
*/
export function debounce(fn, timeout, flag) {
  let timer = null
  return function (...args) {
    clearTimeout(timer)
    if (!timer && flag) {
      fn.apply(this, args)
    }
    timer = setTimeout(() => {
      fn.apply(this, args)
    }, timeout)
  }
}
```

## 节流
在设定时间之内，只能执行一次函数。
:::tip
函数执行的时间差超过设定时间，不是等于约定时间。
:::

### 方案1 时间戳实现
首次触发直接调用，但是在设定时间能触发的不会执行，因此会丢失最后一次触发。
```js
function throttle(event, wait) {
  let pre = 0;
  return function (...args) {
    if (new Date() - pre > wait) {
      pre = new Date();
      event.apply(this, args);
    }
  };
}
```

### 方案2 定时器实现
每次触发都是延时之后执行，因为触发存在滞后，相当于第一次没触发
```js
function throttle(event, wait) {
  let timer = null;
  return function (...args) {
    if (!timer) {
      timer = setTimeout(() => {
        timer = null;
        event.apply(this, args);
      }, wait);
    }
  };
}
```


### 方案3 时间戳 + 定时器实现
最优方案，保障了首次触发和最后一次触发。
```js
export function throttle(fn, timeout) {
  let timer = null
  let lastTime = 0
  return function (...args) {
    const now = new Date()
    if (now - lastTime > timeout) {
      // 时间戳
      // 1.首次调用立即触发
      // 2.超过设定时长立即触发
      // 3.在设定时长内调用不会触发
      clearTimeout(timer)
      timer = null
      lastTime = now
      fn.apply(this, args)
    } else if (!timer) {
      // 用定时器可以实现最后一次触发
      timer = setTimeout(() => {
        fn.apply(this, args)
        timer = null
      }, timeout)
    }
  }
}
```
