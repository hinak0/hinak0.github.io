---
title: 每日一题-买卖股票的最佳时机III
categories:
  - 算法题每日一练
date: 2023-10-03 14:26:44
tags:
cover:
---

## 问题

[Link](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-iii)

> 给定一个数组，它的第 i 个元素是一支给定的股票在第 i 天的价格。
>
> 设计一个算法来计算你所能获取的最大利润。你最多可以完成**两笔**交易。
>
> 注意：你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。
>
> 难度：困难

## 思路

- 题目限定了只能进行两笔交易，显然贪心算法这种方法不考虑交易不行
- 使用动态规划解法，定义状态dp[i]代表第i天结束时手里的钱数
- 定义状态sell1,buy1,sell2,buy2代表买了一次，买卖一次，买卖一次+买了二次，买买二次
- 每天的状态只和前一天有关，无需存储整个数组，所以状态转移方程为：
  ```plain
  buy1 = max(buy1, -prices[i]);
  sell1 = max(sell1, buy1 + prices[i]);
  buy2 = max(buy2, sell1 - prices[i]);
  sell2 = max(sell2, buy2 + prices[i]);
  ```
- 接下来考虑初始状态，第0天如果手里买进了，就是-prices[0]，没有就是0。

## 代码

```js
/**
 * @param {number[]} prices
 * @return {number}
 */
var maxProfit = function (prices) {
	let buy1 = -prices[0],
		buy2 = -prices[0],
		sell1 = 0,
		sell2 = 0;
	for (let i = 0; i < prices.length; i++) {
		buy1 = Math.max(buy1, -prices[i]);
		sell1 = Math.max(sell1, buy1 + prices[i]);
		buy2 = Math.max(buy2, sell1 - prices[i]);
		sell2 = Math.max(sell2, buy2 + prices[i]);
	}
	return sell2;
};
```

## 其他题解

### 暴力算法

1. 计算出所有上坡，排序
2. 选择落差最大的两个，相加。
