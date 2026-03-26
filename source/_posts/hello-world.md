---
title: Hello World - Test Post
date: 2026-03-26 14:35:00
categories:
  - Test
tags:
  - test
  - hello
cover:
---

This is a test post to verify the theme styles are working correctly.

<!-- more -->

## Headings

# H1 Heading

## H2 Heading

### H3 Heading

#### H4 Heading

## Text Styles

Normal text paragraph. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

**Bold text** and _italic text_ and ~~strikethrough text~~.

> This is a blockquote. It can span multiple lines and is used to highlight important information.

## Code

Inline code: `console.log("Hello, World!")`

```javascript
// Code block example
function greet(name) {
	return `Hello, ${name}!`;
}

console.log(greet("World"));
```

```python
# Python example
def greet(name):
    return f"Hello, {name}!"

print(greet("World"))
```

## Lists

### Unordered List

- Item one
- Item two
  - Nested item
  - Another nested item
- Item three

### Ordered List

1. First item
2. Second item
3. Third item

## Table

| Name     | Type   | Description       |
| -------- | ------ | ----------------- |
| title    | string | The post title    |
| date     | date   | The publish date  |
| category | string | The post category |
| tags     | array  | Tags for the post |

## Links

[Visit GitHub](https://github.com)

## Note Tag

{% note info flat %} This is an info note. The theme supports various note styles. {% endnote %}

{% note success flat %} Theme styles are working correctly! {% endnote %}

{% note warning flat %} This is a warning note. {% endnote %}
