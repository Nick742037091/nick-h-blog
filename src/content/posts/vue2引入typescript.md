---
title: vue2引入typescript
published: 2025-01-20
description: '升级vue2项目，在尽量缩小改动范围的情况下，引入typescript'
image: '../../assets/images/articles/vue2引入组合式api/vuejs.jpg'
tags: ['vue','vue2','typescript']
category: '前端'
lang: 'zh_CN'
---
# vue2引入typescript(vue-cli篇)

## 安装typescript相关依赖
通过@vue/cli的`vue add`命令安装，可以自动补充和typescript关联的依赖，避免版本号不对应导致的冲突
```
vue add typescript
```
配置如下
![alt text](../../assets/images/articles/vue2引入组合式api/vue_add_typescript_1.png)

执行完文件更新如下
![alt text](../../assets/images/articles/vue2引入组合式api/vue_add_typescript_2.png)

除了`HelloWorld.vue`文件的更新，其他需要保留。

### .eslintrc.js更新如下
```js
module.exports = {
  extends: [
    //...
    // 新增typescript扩展
    '@vue/typescript'
  ],
  parserOptions: {
    // 更新解析器，支持ts
    parser: '@typescript-eslint/parser',
  },
};
```

### package.json新增了typescript相关的依赖
```json
"devDependencies": {
    "@typescript-eslint/eslint-plugin": "^5.4.0",
    "@typescript-eslint/parser": "^5.4.0",
    "@vue/cli-plugin-typescript": "^5.0.8",
    "@vue/eslint-config-typescript": "^9.1.0",
    "typescript": "~4.5.5",
  }
```

### 新增了jsx和vue实例ts声明
```ts
// shims-tsx.d.ts
import Vue, { VNode } from "vue";

declare global {
  namespace JSX {
    interface Element extends VNode {}
    interface ElementClass extends Vue {}
    interface IntrinsicElements {
      [elem: string]: any;
    }
  }
}
```

```ts
// shims-vue.d.ts
declare module "*.vue" {
  import Vue from "vue";
  export default Vue;
}
```

### main.js被转换为main.ts
有可能会出现异常，可以保留原来的main.js文件，直接把后缀改成.ts，然后在文件开头声明
```main.js
// @ts-nocheck
```
可以临时绕过ts检测，后续再完善。

## IDE类型补全(可选)
如果使用了unplugin-vue2-script-setup插件，为了使vue office插件能在template中获取ts类型，需要做以下调整：
1. 安装@vue/runtime-dom
```shell
npm i -D @vue/runtime-dom
or
yarn add -D @vue/runtime-dom
```
2.在tsconfig.json中补充types
```json
{
  "compilerOptions": {
    "types": [
      "unplugin-vue2-script-setup/types"
    ]
  }
}
```

## 总结
1. vue2手动安装typescript插件还是挺麻烦的，特别是需要与eslint兼容，不同版本容易出现冲突，建议使用`vue add typescript`进行自动化处理，然后再进行微调。
2. 使用`unplugin-vue2-script-setup`时，模板上的ts类型推导功能还不够完善，需要搭配`@vue/runtime-dom`使用。




