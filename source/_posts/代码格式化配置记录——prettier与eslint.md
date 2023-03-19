---
title: "代码格式化配置记录——prettier与eslint"
date: "2022-10-26"
categories:
  - "web技术"
---

#### 两工具侧重点有区别，eslint注重代码检查，prettier更注重代码格式化。

## prettier

### 官方文档:[prettier configuration](https://prettier.io/docs/en/configuration.html)

### 默认忽略文件配置路径：`./.prettierignore`

### 配置样例

```
// overrides: [
//   {
//     files: ['*.nvue'],
//     options: {
//       parser: 'vue',
//     },
//   },
// ],
// 末尾不需要逗号 'es5' noneF
trailingComma: 'es5',
// 大括号内的首尾需要空格
bracketSpacing: true,
// 行尾分号
semi: false,
// 使用单引号
singleQuote: true,
// 一行最多 100 字符
printWidth: 100,
// 使用缩进符
useTabs: true,
// 使用 2 个空格缩进
tabWidth: 3,
// 对象的 key 仅在必要时用引号
//quoteProps: 'as-needed',
// jsx 不使用单引号，而使用双引号
//jsxSingleQuote: false,
// jsx 标签的反尖括号需要换行
//jsxBracketSameLine: false,
// 箭头函数，只有一个参数的时候，也需要括号
//arrowParens: 'always',
// 每个文件格式化的范围是文件的全部内容
rangeStart: 0,
rangeEnd: Infinity,
// 不需要写文件开头的 @prettier
//requirePragma: false,
// 不需要自动在文件开头插入 @prettier
//insertPragma: false,
// 使用默认的折行标准
//proseWrap: 'preserve',
// 根据显示样式决定 html 要不要折行
//htmlWhitespaceSensitivity: 'css',
// 换行符使用 lf 结尾是 \n \r \n\r auto
//endOfLine: 'lf',
// Vue 文件脚本和样式标签缩进‍
vueIndentScriptAndStyle: false,
```

### 命令行

`prettier --config .prettierrc.js --write ./**/**/*.{js,css,vue,html,json}`

## eslint

### 配置样例

```
"eslintConfig": {
	"ignorePatterns": [
		"example.js"
	],
	"root": true,
	"env": {
		"node": true
	},
	"extends": [
		"plugin:vue/essential",
		"eslint:recommended"
	],
	"parserOptions": {
		"parser": "@babel/eslint-parser"
	},
	"rules": {
		"no-use-before-define": "off",
		"no-unused-vars": "off",
		"no-redeclare": "off",
		"indent": [
			"error",
			"tab"
		],
		"no-undef": "off",
		"no-empty": "off",
		"vue/multi-word-component-names": "off",
		"vue/require-v-for-key": "off",
		"vue/html-indent": [
			"error",
			"tab",
			{
				"attribute": 1,
				"baseIndent": 1,
				"closeBracket": 0,
				"alignAttributesVertically": true,
				"ignores": []
			}
		]
	}
```

### 命令行：`eslint --fix --ext .vue,.js ./`
