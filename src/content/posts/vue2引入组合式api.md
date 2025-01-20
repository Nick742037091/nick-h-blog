---
title: vue2引入组合式api
published: 2025-01-20
description: '升级vue2项目，在尽量缩小改动范围的情况下，引入组合式api'
image: '../../assets/images/articles/vue2引入组合式api/vuejs.jpg'
tags: ['vue','vue2','组合式api']
category: '前端'
lang: 'zh_CN'
---
##

# vue2引入组合式api


## vue版本小于v2.7

vue版本小于2.7，只能通过安装[@vue/composition-api](https://www.npmjs.com/package/@vue/composition-api)引入组合式api，有一点点性能影响，但是可以接受。

### @vue/composition-api(必需)

#### 安装
```shell
npm install @vue/composition-api
# or
yarn add @vue/composition-api
```

#### 全局引入
```js
import Vue from 'vue'
import VueCompositionAPI from '@vue/composition-api'

Vue.use(VueCompositionAPI)
```

### 组件内使用组合式api
```vue
<template>
  <div>
    <button @click="increment">Increment</button>
    <button @click="decrement">Decrement</button>
    <h1>{{ count }}</h1>
  </div>
</template>

<script>
// 组合式api通过@vue/composition-api导入
import { defineComponent, ref } from "@vue/composition-api";
export default defineComponent({
  setup() {
    const count = ref(0);
    const increment = () => {
      count.value++;
    };
    const decrement = () => {
      count.value--;
    };
    return {
      count,
      increment,
      decrement,
    };
  },
});
</script>
```

### unplugin-vue2-script-setup(可选)
组合式api配合`script setup`才好用，但是`@vue/composition-api`无法直接使用`script setup`，需要安装[unplugin-vue2-script-setup](https://www.npmjs.com/package/unplugin-vue2-script-setup)插件。一般vue2项目是是通过vue-cli/webpack搭建的，这里以vue-cli为例

#### 安装

```shell
npm i -D unplugin-vue2-script-setup
# or
yarn add -D unplugin-vue2-script-setup
```

```js
// vue.config.js
const ScriptSetup = require('unplugin-vue2-script-setup/webpack').default

module.exports = {
  parallel: false, // 关闭thread-loader, 和这个插件有冲突
  configureWebpack: {
    plugins: [
      ScriptSetup(),
    ],
  },
}
```

#### 组件内调整为script setup
```vue
<template>
  <div>
    <button @click="increment">Increment</button>
    <button @click="decrement">Decrement</button>
    <h1>{{ count }}</h1>
  </div>
</template>

<script setup>
import { ref } from '@vue/composition-api'
const count = ref(0)
const increment = () => {
  count.value++
}
const decrement = () => {
  count.value--
}
</script>
```


## vue版本大于v2.7
组合式api通过`vue`依赖直接导入，也默认支持`script setup`，性能也更好。
```vue
<script setup>
import { ref } from "vue";
// ...
</script>
```

## 总结
1. vue2.7版本使用组合式api更方便，vue2.7以下也能使用插件引入，也不麻烦。
2. 引入组合式api之后，强烈建议把typesciprt也引入。vue最舒适的开发方式是`组合式api` + `script setup` + `typescript`。
3. vue升级到2.7版本调整内容挺多，需要谨慎考虑。



