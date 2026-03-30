---
title: 你好世界 - 测试文章
date: 2026-03-26 14:35:00
categories:
  - 测试
tags:
  - 测试
  - 你好
cover:
---

这是一篇测试文章，用于验证主题样式是否正常渲染。

<!-- more -->

## 标题

# 一级标题

## 二级标题

### 三级标题

#### 四级标题

---

## 文字样式

普通段落文字。这里是一段示例正文，用于测试主题的基础排版效果，包括字体、行距与段落间距是否符合预期。

**粗体文字**、_斜体文字_、~~删除线文字~~。

> 这是一段引用块。引用块可以跨越多行，通常用于标注重要信息或摘录内容。

---

## 代码

内联代码示例：`console.log("你好，世界！")`

```javascript
// JavaScript 代码块示例
function greet(name) {
  return `你好，${name}！`;
}

console.log(greet("世界"));
```

```python
# Python 代码块示例
def greet(name):
    return f"你好，{name}！"

print(greet("世界"))
```

```typescript
// TypeScript 代码块示例
interface User {
  name: string;
  age: number;
}

function greet(user: User): string {
  return `你好，${user.name}！你今年 ${user.age} 岁。`;
}

console.log(greet({ name: "世界", age: 1 }));
```

```bash
# Bash 代码块示例
echo "你好，世界！"
hexo clean && hexo generate && hexo server
```

---

## 列表

### 无序列表

- 第一项
- 第二项
  - 嵌套子项
  - 另一个嵌套子项
- 第三项

### 有序列表

1. 第一步
2. 第二步
3. 第三步

### 任务列表

- [x] 已完成的任务
- [x] 已验证主题样式
- [ ] 待完成的任务
- [ ] 持续补充测试内容

---

## 表格

| 字段名   | 类型   | 说明           |
| -------- | ------ | -------------- |
| title    | string | 文章标题       |
| date     | date   | 发布日期       |
| category | string | 文章分类       |
| tags     | array  | 文章标签       |
| cover    | string | 封面图片路径   |

---

## 链接与图片

[访问 GitHub](https://github.com)

图片语法测试：

![占位图示例](https://placehold.co/600x200?text=测试图片)

---

## 提示标签

{% note info flat %} 这是一条信息提示。主题支持多种提示标签样式。 {% endnote %}

{% note success flat %} 主题样式渲染正常！ {% endnote %}

{% note warning flat %} 这是一条警告提示，请注意相关内容。 {% endnote %}

{% note danger flat %} 这是一条危险提示，操作前请务必确认。 {% endnote %}

{% note tip flat %} 这是一条小技巧提示，帮助你更好地使用本主题。 {% endnote %}
