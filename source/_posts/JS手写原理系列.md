---
title: JS手写原理系列
categories:
  - "web技术"
date: 2023-04-08 21:04:55
tags:
---

Some boilerplate of javascript.

### debounce()
```js
function debounce(fn, wait) {
	let timer = null
	return function (...args) {
		if (timer) clearTimeout(timer)
		timer = setTimeout(() => {
			fn()
		}, wait)
	}
}
function test() {
	console.log('hello')
}
let myFn = debounce(test, 1000)
myFn()
myFn()
myFn()
myFn()
```

### sleep()
sleep() can only use in an async function , and　the sleep() mast marked with `await`
```js
async function sleep(delay) {
	return new Promise(resolve => {
		setTimeout(() => {
			resolve()
		}, delay)
	})
}

// how to use it
async function test() {
	console.log('start')
	await sleep(3000)
	console.log('execute')
}

test()
```

## A simple Pubsub
```js
class PubSub {
	constructor() {
		this.topics = {}
	}
	sub(topic, callBack) {
		if (!this.topics[topic]) {
			this.topics[topic] = [callBack]
		} else {
			this.topics[topic].push(callBack)
		}
	}
	unsub(topic, callBack) {
		if (!this.topics[topic]) return
		this.topics[topic] = this.topics[topic].filter(item => {
			return item !== callBack
		})
	}
	subOnce(topic, callBack) {
		function fn() {
			callBack()
			this.off(topic, fn)
		}
		this.sub(topic, fn)
	}
	pub(topic, ...params) {
		this.topics[topic] && this.topics[topic].forEach(fn => fn.apply(this, params))
	}
}
```

## reference
[zhihu](https://zhuanlan.zhihu.com/p/462393494)
