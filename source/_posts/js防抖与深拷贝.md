---
title: "js防抖与深拷贝"
date: "2022-03-23"
categories:
  - "web"
---

## js防抖

```
function debounce(fn, wait) {
   let timer = null;
   return function (...args) {
      if (timer) clearTimeout(timer);
      timer = setTimeout(() => {
         fn()
      }, wait)
   }
}
function fn() {
   console.log("hello");
}
let myFn = debounce(fn, 1000)
```

值得注意的是，应该在使用时调用myFn（）这个函数（这里应该是形成了闭包），类似下面的代码无法实现功能

```
<button onclick="debounce(fn, 1000)">click me</button>
function debounce(fn, wait) {
   let timer = null;
   if (timer) clearTimeout(timer);
      timer = setTimeout(() => {
         fn()
   }, wait)
}

```

原因是这种方式实际上是包装了一个新的函数，占据一个新的变量空间，无法访问上一次的timer

## 深拷贝

```
let obj1 = [{
   name: "chen",
   age: 20
}, {
   name: "su",
   age: 20
}, {
   name: "hi",
   age: 20
}]
function func() {
   // let obj2 = obj1 // 浅拷贝
   // let obj2 = [...obj1] // 由于obj1内部仍然为对象，依然是浅拷贝
   let obj2 = JSON.parse(JSON.stringify(obj1))  // 深拷贝
   obj2[0].name = "x"
   console.log("1",obj1);
   console.log("2",obj2);
}
```

也有通过递归到基本数据类型实现深拷贝的，不再赘述。
