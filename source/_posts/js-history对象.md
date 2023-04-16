---
title: JS HISTORY对象
date: 2022-07-10
categories:
  - web技术
---

## history是什么

是从新建一个标签页开始，所有打开过的url的一个栈，浏览器根据这个维护 前进，后退 功能。

详细mdn文档[https://developer.mozilla.org/zh-CN/docs/Web/API/History](https://developer.mozilla.org/zh-CN/docs/Web/API/History)

## 案例

[https://app.noy.asia/#/preview/4116](https://app.noy.asia/#/preview/4116)

这个网站实现了一个流氓功能：后退的话，会向history中push一个state，导致无法退出这个页面——除非关掉这个标签页。

## 实现禁止后退功能

```js
history.pushState(null, null, document.URL);
// 每当触发后退事件时，就再加一个当前页面的记录
window.addEventListener("popstate", e => {
	alert("popstate")
	history.pushState(null, null, document.URL);
	console.log("you can't go back");
})
```

或者做绝一点，像这样：

```js
for (let index = 0; index < 5; index++) {
	history.pushState(null, null, document.URL);
}
```

## 如何屏蔽这种行为？

幸好,chrome已经有针对这种行为的应对策略了，经过测试，再进入一个标签页后，如果不进行任何操作，不会触发popstate事件，此举正是为了防范流氓网站。

但是其他浏览器比如via浏览器，并没有这个功能。

其他浏览器，如果你想做一个屏蔽流氓网站的插件，可以这么做：在刚刚进入页面时，通过Object.defineProperty()等方法来覆盖history对象的popstate方法，同时设置一个变量保存原本的方法，在用户做出交互行为后恢复popstate方法就好了。
