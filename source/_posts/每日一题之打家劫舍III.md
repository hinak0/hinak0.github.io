---
title: 每日一题之打家劫舍III
categories:
  - 算法题每日一练
date: 2023-09-18 14:31:26
tags:
cover:
---

## 问题

[Link](https://leetcode.cn/problems/house-robber-iii/)

> 小偷又发现了一个新的可行窃的地区。这个地区只有一个入口，我们称之为 root 。
>
> 除了 root 之外，每栋房子有且只有一个“父“房子与之相连。一番侦察之后，聪明的小偷意识到“这个地方的所有房屋的排列类似于一棵二叉树”。 如果 两个直接相连的房子在同一天晚上被打劫 ，房屋将自动报警。
>
> 给定二叉树的 root 。返回 在不触动警报的情况下 ，小偷能够盗取的最高金额 。

## 思路

1. 子问题是节点k的左右节点的最大收获。
2. 我们可以用`f(o)`表示选择o节点的情况下，o节点的子树上被选择的节点的最大权值和；`g(o)`表示不选择o节点的情况下，o节点的子树上被选择的节点的最大权值和；
3. 当o被选中时，左右节点不能选中，也就是`f(o)=g(l)+g(r)+o`
4. 当o不选中时，`g(o)=max{f(l),g(l)}+max{f(r),g(r)}`
5. 使用深度优先遍历二叉树

## 代码

```java
import java.util.HashMap;
import java.util.Map;

class Solution {
	Map<TreeNode, Integer> f = new HashMap<TreeNode, Integer>();
	Map<TreeNode, Integer> g = new HashMap<TreeNode, Integer>();

	public int rob(TreeNode root) {
		dfs(root);
		return Math.max(f.getOrDefault(root, 0), g.getOrDefault(root, 0));
	}

	public void dfs(TreeNode node) {
		if (node == null) {
			return;
		}
		dfs(node.left);
		dfs(node.right);
		f.put(node, node.val + g.getOrDefault(node.left, 0) + g.getOrDefault(node.right, 0));
		g.put(node,
				Math.max(f.getOrDefault(node.left, 0), g.getOrDefault(node.left, 0)) +
						Math.max(f.getOrDefault(node.right, 0), g.getOrDefault(node.right, 0)));
	}
}
```

## 优化

1. 空间优化：在dfs时将f(x)和g(x)的值全都返回给上一级，可以省去哈希表空间。
