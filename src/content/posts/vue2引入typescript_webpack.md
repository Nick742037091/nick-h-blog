---
title: vue2引入typescript(webpack篇)
published: 2025-01-22
description: '升级vue2项目，在尽量缩小改动范围的情况下，引入typescript'
image: '../../assets/images/articles/vue2引入组合式api/vuejs.jpg'
tags: ['vue','vue2','typescript','webpack']
category: '前端'
lang: 'zh_CN'
---

相比[vue-cli引入typescript](/posts/vue2引入typescript_vue-cli/)，webpack引入typescript没法自动化，要麻烦一些。


:::tip
本篇文章基于webpack4，记录的是最基本的操作方法。实际项目中可以会遇到其他各种各样的问题，建议使用[Cursor](https://www.cursor.com/)、[Trae](https://www.trae.ai/)等智能IDE进行辅助。
:::

# 安装ts相关依赖
```shell
npm i -D typescript@4.1.6 ts-loader@7.0.5 
```

:::warning
这是基于wepack4的依赖版本号，如果是其他版本的webpack，请向AI查询对应的依赖版本号。
:::

# 修改入口文件
将main.js该为main.ts，加入@ts-nocheck声明，临时绕过ts检测，后续再完善。
```main.js
// @ts-nocheck
```

# 调整webpack配置
```js
module.exports = {
  entry: {
    // 将入口文件改完main.ts
    app: './src/main.ts'
  },
  resolve: {
    // 增加'.ts', '.tsx'，支持解析ts文件
    extensions: ['.js', '.vue', '.json', '.ts', '.tsx']
    //...
  },
  modules :{
    rules:[
      // 在支持解析ts文件的基础上，引导使用ts-loader对ts/tsx文件进行处理
      {
        // .vue文件中的typescript代码块会被拆分为ts文件进行处理，所以这里的test能匹配上
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/,
        options: {
          // 这句很重要，支持处理.vue文件中的ts语句
          appendTsSuffixTo: [/\.vue$/],
          transpileOnly: true
        }
      },
      //...
    ]
  }
}
```

# 添加tsconfig.json
在根目录手动添加tsconfig.json文件
* `target`为`ES5`，将编译产物设置为较低版本的js，避免各种高版本语法（如可选链）无法被识别。
* `allowJs`为`true`，历史的js版本才能正常运行 
```json
{
  "compilerOptions": {
    "target": "ES5",
    "module": "esnext",
    "strict": true,
    "jsx": "preserve",
    "skipLibCheck": true,
    "importHelpers": true,
    "moduleResolution": "node",
    "allowJs": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "sourceMap": true,
    "baseUrl": ".",
    "types": [
      "webpack-env",
    ],
    "paths": {
      "@/*": [
        "src/*"
      ]
    },
    "lib": [
      "esnext",
      "dom",
      "dom.iterable",
      "scripthost"
    ],
  },
  "include": [
    "src/**/*.ts",
    "src/**/*.tsx",
    "src/**/*.vue",
    "tests/**/*.ts",
    "tests/**/*.tsx"
  ],
  "exclude": [
    "node_modules"
  ]
}
```

# 添加ts声明文件
src目录下添加两个声明文件
## shims-tsx.d.ts
jsx声明文件，可在global中补充全局属性
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

## shims-vue.d.ts
vue实例声明文件，缺少这个文件，在ts文件中导入.vue文件会提示找不到类型。
```ts
// shims-vue.d.ts
declare module "*.vue" {
  import Vue from "vue";
  export default Vue;
}
```


# IDE类型补全(可选)
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

# 总结
1. vue2引入typescript比较麻烦，建议使用[Cursor](https://www.cursor.com/)、[Trae](https://www.trae.ai/)等IDE进行辅助。
2. 主要流程包括：引入ts库和ts-loader -> 修改webpack配置和项目入口 -> 添加ts配置文件 -> 补充ts声明文件。