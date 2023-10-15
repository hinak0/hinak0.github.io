---
title: hexo主题开发中的洗牌算法
categories:
  - Code & Program
date: 2023-10-08 22:38:30
tags:
cover:
---

## 背景

今天打开博客页面，发现主页这么呈现：

![](images/20231008-224621.png)

很明显是因为随机封面算法是真随机，于是找到现在在用的主题butterfly中，随机封面的算法如下：

```js
const randomCoverFn = () => {
	const {
		cover: { default_cover: defaultCover },
	} = hexo.theme.config;
	if (!defaultCover) return false;
	if (!Array.isArray(defaultCover)) return defaultCover;
	const num = Math.floor(Math.random() * defaultCover.length);
	return defaultCover[num];
};
```

强迫症简直不能忍，于是立马写一个shuffle函数

## 闭包+克隆数组的写法

这是想到的最简单的一个办法，写法也简单：

```js
const defaultCover = ['1', '2', '3', '4', '5'];

const randomCoverFn = (() => {
	if (!defaultCover) return false;
	if (!Array.isArray(defaultCover)) return defaultCover;

	const shuffle = [...defaultCover];
	let lastChoice = null;
	return function () {
		//重新加牌
		if (shuffle.length < 2) {
			shuffle.push(...defaultCover);
		}

		// 防止重新加牌后产生重复，记录上次选择
		let num;
		do {
			num = Math.floor(Math.random() * shuffle.length);
		} while (shuffle[num] === lastChoice);

		// 去掉选择过的
		let res = shuffle.splice(num, 1)[0];
		lastChoice = res;
		return res;
	};
})();

let last = null;
for (let i = 0; i < 1000; i++) {
	let s = randomCoverFn();
	if (last === s) {
		console.log('error !');
	}
	last = s;
}
```

这个办法问题多多：

1. 不够优雅
2. 都记录上次选择了，何必辛苦克隆数组

于是优化版本:

```js
const defaultCover = ['1', '2', '3', '4', '5'];

const randomCoverFn = (() => {
	if (!defaultCover) return false;
	if (!Array.isArray(defaultCover)) return defaultCover;

	let lastChoice = null;
	return function () {
		let num;
		do {
			num = Math.floor(Math.random() * defaultCover.length);
		} while (lastChoice === num);
		lastChoice = num;

		return defaultCover[num];
	};
})();

let last = null;
for (let i = 0; i < 1000; i++) {
	let s = randomCoverFn();
	if (last === s) {
		console.log('error !');
	}
	last = s;
}
```

这个办法不错，但测试下来也有缺点，可能出现[1,2,1,2,1,2]这种重复排列，不够完美。

查到资料，有一种`Fisher–Yates shuffle`算法，更巧妙，链接在这里：

[Fisher–Yates shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle)

## Fisher–Yates shuffle

```js
'use strict';

var randomCoverFn;

const createShuffleClosure = (arr) => {
	const shuffledArray = [...arr];
	const currentShuffleList = [];
	let lastChioce;

	const shuffle = () => {
		// https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
		let currentIndex = arr.length;
		while (currentIndex !== 0) {
			const randomIndex = Math.floor(Math.random() * currentIndex);
			currentIndex--;

			// Swap elements between currentIndex and randomIndex
			const tempValue = shuffledArray[currentIndex];
			shuffledArray[currentIndex] = shuffledArray[randomIndex];
			shuffledArray[randomIndex] = tempValue;
		}
		return [...shuffledArray]; // Return a new shuffled array
	};

	const getOneFromShuffled = () => {
		// flush shuffledList if necessary
		if (currentShuffleList.length === 0) {
			do {
				currentShuffleList.splice(0);
				currentShuffleList.push(...shuffle());
			} while (
				currentShuffleList[currentShuffleList.length - 1] === lastChioce
			);
		}

		return currentShuffleList.pop();
	};

	return getOneFromShuffled;
};

hexo.on('generateBefore', () => {
	const {
		cover: { default_cover: defaultCover },
	} = hexo.theme.config;

	if (!defaultCover) {
		randomCoverFn = () => false;
		return;
	}
	if (!Array.isArray(defaultCover)) {
		randomCoverFn = () => defaultCover;
		return;
	}

	randomCoverFn = createShuffleClosure(defaultCover);
});
```

这种算法完美解决了上述问题
