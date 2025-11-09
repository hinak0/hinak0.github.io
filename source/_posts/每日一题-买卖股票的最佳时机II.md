---
title: 每日一题-买卖股票的最佳时机II
categories:
  - 算法题每日一练
date: 2023-10-02 14:46:28
tags:
cover:
---

## 问题

[Link](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii)

> 给你一个整数数组 prices ，其中 prices[i] 表示某支股票第 i 天的价格。
>
> 在每一天，你可以决定是否购买和/或出售股票。你在任何时候 最多 只能持有 一股 股票。你也可以先购买，然后在 同一天 出售。
>
> 返回 你能获得的 最大 利润 。

## 思路

题目没说不可以同一天卖了又买。所以贪心算法，将折线图中所有上坡都收集到，就是最大利润。

## 代码

```js
/**
 * @param {number[]} prices
 * @return {number}
 */
var maxProfit = function (prices) {
	let ans = 0;
	for (let i = 1; i < prices.length; i++) {
		let profit = prices[i] - prices[i - 1];
		if (profit > 0) {
			ans += profit;
		}
	}
	return ans;
};
```

## 官方题解

### 动态规划法

1. dp[i][j]表示第i天手里有无股票(j=0无股票，1有股票)
2. dp[i][0]=max{dp[i−1][0],dp[i−1][1]+prices[i]}
3. dp[i][1]=max{dp[i−1][1],dp[i−1][0]−prices[i]}

#### 代码

```js
var maxProfit = function (prices) {
	const n = prices.length;
	const dp = new Array(n).fill(0).map((v) => new Array(2).fill(0));
	((dp[0][0] = 0), (dp[0][1] = -prices[0]));
	for (let i = 1; i < n; ++i) {
		dp[i][0] = Math.max(dp[i - 1][0], dp[i - 1][1] + prices[i]);
		dp[i][1] = Math.max(dp[i - 1][1], dp[i - 1][0] - prices[i]);
	}
	return dp[n - 1][0];
};
```

觉得有点简单问题复杂化了
