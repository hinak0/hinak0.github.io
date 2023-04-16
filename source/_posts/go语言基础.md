---
title: go语言基础
date: 2023-03-30 17:02:29
categories:
  - 后端
tags:
---

个人认为和js,py不同的地方

[菜鸟教程](https://www.runoob.com/go/go-tutorial.html)

## 数组
```go
var balance = [5]float32{1000.0, 2.0, 3.4, 7.0, 50.0}
balance := [5]float32{1000.0, 2.0, 3.4, 7.0, 50.0}
// 编译器确定长度
balance := [...]float32{1000.0, 2.0, 3.4, 7.0, 50.0}
```

## 切片（可变数组）
```go
// init
s :=[] int {1,2,3 }
s :=make([]int,len,cap)

// 截取，和py一致
numbers[1:4]

// append() and copy()
var numbers []int
numbers = append(numbers, 0)
copy(numbers1,numbers)
```

## 指针
```go
i := 8
f := 3.00
var ip *int
var fp *float64
// 取地址
ip = &i
fp = &f
fmt.Printf("%d\n", *ip)
fmt.Printf("%f\n", *fp)
fmt.Printf("%x\n", ip)
fmt.Printf("%x\n", fp)
```


## map集合
```go
m := map[string]int{
	"ゼロ": 0,
}
m["いち"]=1
m["に"]=2
m["さん"]=３

delete(m,"ゼロ")
```

## range遍历
```go
var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow {
		// do somethings
		// i,v是索引和值
	}
}
```

## 函数
```go
func sum(s string, nList ...int) int {
	// 类似es6的拓展运算符，以切片形式接受变长参数
	fmt.Println("received vars:", s, nList)
	var res int = 0
	for _, v := range nList {
		res += v
	}
	return res
}

func main() {
	arr := []int{1, 2, 3, 4}
	// 类似es6的拓展运算符
	res := sum("hello", arr...)
	fmt.Println("result of sun(): ", res)
	fmt.Println()

	res = sum("hello", arr[0], arr[1])
	fmt.Println("result of sun(): ", res)
}
```

## 类型转换
```go
a := int 16
b := float64 = float64(a)
```

#### 字符串类型转换
```go
// str -> int
var str string = "10"
var num int
num, _ = strconv.Atoi(str)

// int -> str
num := 123
str := strconv.Itoa(num)
```

## 接口类型变量
```go
// init
type Phone interface {
	call(param int) string
	takephoto()
}

type Huawei struct {
}

func (huawei Huawei) call(param int) string{
	fmt.Println("i am Huawei, i can call you!", param)
	return "damon"
}

func (huawei Huawei) takephoto() {
	fmt.Println("i can take a photo for you")
}


func main() {
	phone := Phone
	phone = new(Huawei)
	phone.takephoto()
	r := phone.call(50)
	fmt.Println(r)
}
```

## go并发
这个我觉得是比较有意思的，通过并发和channel使得多线程很方便

#### 通道chan
通道（channel）是用来传递数据的一个数据结构。

通道可用于两个 goroutine 之间通过传递一个指定类型的值来同步运行和通讯。操作符 <- 用于指定通道的方向，发送或接收。如果未指定方向，则为双向通道。

默认情况下，通道是不带缓冲区的。发送端发送数据，同时必须有接收端相应的接收数据.

带缓冲区的通道允许发送端的数据发送和接收端的数据获取处于异步状态，就是说发送端发送的数据可以放在缓冲区里面，可以等待接收端去获取数据，而不是立刻需要接收端去获取数据。
```go
func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i < n; i++ {
		c <- x
		fmt.Printf("trans %d\n", x)
		time.Sleep(100 * time.Millisecond)
		x, y = y, y+1
	}
	close(c)
}

func main() {
	c := make(chan int, 5)
	go fibonacci(2*cap(c), c)
	time.Sleep(5 * time.Second)
	for i := range c {
		// 这里会阻塞fibonacci线程
		time.Sleep(1 * time.Second)
		fmt.Printf("recive %d\n", i)
	}
}
```

输出应该是这样：

```text
trans 0
trans 1
trans 2
trans 3
trans 4
trans 5
recive 0
trans 6
recive 1
trans 7
recive 2
trans 8
recive 3
trans 9
recive 4
recive 5
recive 6
recive 7
recive 8
recive 9
```

## 包管理

go的包管理有些麻烦，我在这里也摸了大坑．

go1.1１以后增加了module模式，由环境变量`GO111MODULE`控制

### 非mod模式
- 此时的go没有项目的概念，非常杂乱．
- `GOROOT`和`GOPATH`是两个重要的环境变量．导入包时，在上面两个路径下的src目录寻找模块．
- 如果想自定义模块，必须放在`$GOPATH/src`下才能导入

### mod模式
- 项目下的`go.mod`类似`package.json`,`requirements.txt`,`pom.xml`
- 同项目下的`module`可以直接引用，不需要src目录．
- 依赖管理用`go mod`系列指令[文档](http://c.biancheng.net/view/5712.html)
