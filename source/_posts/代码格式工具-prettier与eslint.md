---
title: 代码格式工具-prettier与eslint
date: 2022-10-26
categories:
  - Code & Program
---

#### 两工具侧重点有区别，eslint注重代码检查，prettier更注重代码格式化。

## prettier

官方文档:[prettier configuration](https://prettier.io/docs/en/configuration.html)

默认忽略文件配置路径：`./.prettierignore`，格式同`.gitignore`

### 配置样例如下：

.prettierrc.yaml

```yaml
# 使用tab换行
useTabs: true
# 每个缩进空格数
tabWidth: 2
# 一行最大长度
printWidth: 100
# xml末尾">"不单独一行
bracketSameLine: true
# markdown一个段落一行
proseWrap: never
# overrides:
#   - files: "*.md"
#     options:
#       printWidth: 9999
```

### 命令行

`prettier --write .`

## eslint

### 配置样例

```json
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
