---
title: 外部脚本改变react受控组件状态
categories:
  - web技术
date: 2023-04-26 15:04:55
tags:
cover:
---

最近写一个浏览器脚本，需要实现一个自动化输入的功能，也就是脚本改变输入框内容．网页是使用react写的，记录一下．

## 如何更改（原理）

直接`element.value = xx`赋值当然不行，因为状态保存在组件实例中，直接更改的话，会在下一次视图刷新中被还原

使用js修改组件实例呢？也不行．因为在外部js,无法获得实例对象，实例是一个闭包．

于是只能用模拟触发输入时的事件来触发数据绑定，进而实现修改实例．

触发事件时，单单`input.dispatchEvent()`还不够，在react中要有特别的方法才能成功触发绑定函数，如下：

## 代码

```js
let input = someInput;
let lastValue = input.value;
input.value = 'new value';
let event = new Event('input', { bubbles: true });
// hack React15
event.simulated = true;
// hack React16 内部定义了descriptor拦截value，此处重置状态
let tracker = input._valueTracker;
if (tracker) {
  tracker.setValue(lastValue);
}
input.dispatchEvent(event);
```

## 参考

[js如何在外部改变react受控组件的状态量？](https://github.com/ILovePing/ILovePing.github.io/issues/22)

