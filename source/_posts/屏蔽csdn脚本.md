---
title: 屏蔽csdn脚本
date: 2022-07-15
categories:
  - web技术
---

```js
// ==UserScript==
// @name         必应搜索引擎优化
// @namespace    https://tampermonkey.net/
// @version      1.0
// @description  屏蔽csdn
// @author       hinak0
// @match        https://cn.bing.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=bing.com
// @grant        none
// ==/UserScript==

(function () {
	'use strict';
	const resultList = document.querySelectorAll('main ol#b_results li.b_algo');
	resultList.forEach((item) => {
		let url = item.querySelector('cite').innerHTML;

		if (url.indexOf('csdn') !== -1) {
			item.innerHTML = '<strong>已屏蔽csdn</strong>';
		}
	});
})();
```
