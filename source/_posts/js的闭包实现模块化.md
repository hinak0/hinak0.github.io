---
title: js的闭包实现模块化
date: 2022-06-22
categories:
  - web技术
---

js可以通过在函数内部定义函数，实现开辟新的作用域，外部无法访问，也就是实现了私有变量。

```
"use strict";
var Clock = (function () {
	let clock = {
		now: new Date(),
		hr: 0,
		minu: 0,
		sec: 0
	}
	// 初始化钟表对象
	function init(el) {
		clock.canvas = document.querySelector(el)
		clock.ctx = clock.canvas.getContext('2d')
		clock.canvas.width = clock.canvas.height = 400
		clock.ctx.translate(clock.canvas.width / 2, clock.canvas.width / 2)
	}
	// 画指针的方法
	function _pointer(length, width, base, num) {
		clock.ctx.beginPath()
		clock.ctx.moveTo(0, 0)
		clock.ctx.lineTo(length * Math.sin(2 * Math.PI * num / base), -length * Math.cos(2 * Math.PI * num / base))
		clock.ctx.lineWidth = width
		clock.ctx.stroke()
	}
	function Hour(hr) {
		_pointer(80, 5.5, 12, hr)
	}
	function Minu(minu) {
		_pointer(110, 2.5, 60, minu)
	}
	function Sec(sec) {
		_pointer(150, 1.5, 60, sec)
	}
	// 更新时间
	function update() {
		clock.now = new Date()
		clock.hr = clock.now.getHours()
		clock.minu = clock.now.getMinutes()
		clock.sec = clock.now.getSeconds()

		// 中点
		clock.ctx.beginPath()
		clock.ctx.arc(0, 0, 5, 0, 2 * Math.PI)
		clock.ctx.fill()

		// 表盘
		clock.ctx.beginPath()
		clock.ctx.arc(0, 0, 180, 0, 2 * Math.PI)
		clock.ctx.lineWidth = "7"
		clock.ctx.stroke()

		// 画刻度
		clock.ctx.beginPath()
		for (let i = 0; i < 12; i++) {
			let angle = Math.PI * i / 6
			clock.ctx.moveTo(180 * Math.sin(angle), 180 * Math.cos(angle))
			clock.ctx.lineTo(160 * Math.sin(angle), 160 * Math.cos(angle))
		}
		clock.ctx.lineWidth = "1.5"
		clock.ctx.stroke()

		// 执行函数
		Hour(clock.hr)
		Minu(clock.minu)
		Sec(clock.sec)
	}

	// 循环动画
	function loop() {
		clock.ctx.clearRect(-1 / 2 * clock.canvas.width, -1 / 2 * clock.canvas.height, clock.canvas.width, clock.canvas.height)
		update()
		window.requestAnimationFrame(loop.bind(this));
	}
	return { init, loop }
})();
```

以上实现了一个canvas绘制钟表的模块，效果可见于[deploy.hinak0.xyz](https://deploy.hinak0.xyz/)。

此模块内所有函数变量，外部均无法访问。

有以下几点注意：

- 非严格模式下，在包内部使用`name = "zhangsan"`会使变量挂载到全局，严格模式则会报错（未定义的变量不允许使用）
- 这种写法代码量比较大，因为使用每个属性时都要带上`clock.key`这种前缀，代码冗余很大，但是胜在全部变量在一个对象\`clock\`内部。
- 可以使用严格模式+变量均在头部声明来简化代码。
