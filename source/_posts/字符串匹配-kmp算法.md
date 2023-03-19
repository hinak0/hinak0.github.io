---
title: "字符串匹配——KMP算法"
date: "2022-04-15"
categories:
  - "算法"
---

## 题目

有两个字符串，要求确定较短字符串在较长字符串中的位置。

## 暴力匹配

![](images/image-edited.png)

使用两层循环，一旦不匹配就将子串后移一位，时间复杂度为O(mn)

## KMP算法

### NEXT\[\]数组

![](images/image-1.png)

![](images/image-2.png)

### 构建next数组

```
private void getNext(String p, int next[]) {
    int len = p.length();
    int right = 0;
    int left = -1;
    next[0] = -1;
    while (right < len - 1) {
        if (left == -1 || p.charAt(right) == p.charAt(left)) {
            right++;
            left++;
            next[right] = left;
        } else
            left = next[left];
    }
}
```

### 匹配过程

```
public int strStr(String target, String pattern) {
    if (pattern.length() == 0)
        return 0;
    int t = 0;
    int p = 0;
    int[] next = new int[pattern.length()];
    getNext(pattern, next);
    while (t < target.length() && p < pattern.length()) {
        if (p == -1 || target.charAt(t) == pattern.charAt(p)) {
            t++;
            p++;
        } else {
            p = next[p];
        }
        if (p == pattern.length())
            return t - p;
    }
    return -1;
}
```
