---
title: 每日一题之打家劫舍II
categories:
  - 算法题每日一练
date: 2023-09-17 09:04:49
tags:
cover:
---

## 问题

[Link](https://leetcode.cn/problems/house-robber-ii)

> 你是一个专业的小偷，计划偷窃沿街的房屋，每间房内都藏有一定的现金。这个地方所有的房屋都 围成一圈 ，这意味着第一个房屋和最后一个房屋是紧挨着的。同时，相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警 。
>
> 给定一个代表每个房屋存放金额的非负整数数组，计算你 在不触动警报装置的情况下 ，今晚能够偷窃到的最高金额。

## 思路

1. 和昨天的问题一样，属于动态规划问题
2. 房子排成环形，只需要分类讨论，第一间房子偷不偷，区间是[0,k-2],[1,k-1]
3. 特殊情况是只有1间或两间房子。
4. 同样可以节省空间，两个变量循环存储dp数组

## 代码

```java
class Solution {
	public int rob(int[] nums) {
		int n = nums.length;
		if (n == 1) {
			return nums[0];
		} else if (n == 2) {
			return Math.max(nums[0], nums[1]);
		} else {
			return Math.max(robRange(nums, 0, n - 2), robRange(nums, 1, n - 1));
		}
	}

	public int robRange(int[] nums, int start, int end) {
		int prev = 0;
		int curr = 0;
		for (int i = start; i <= end; i++) {
			int temp = Math.max(curr, prev + nums[i]);
			prev = curr;
			curr = temp;
		}
		return curr;
	}
}
```
