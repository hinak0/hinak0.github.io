---
title: SpringBoot初试
date: 2022-04-05
categories:
  - 后端
---

## 数据库配置

首先建表：

```sql
CREATE TABLE `user` (
 `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
 `email` varchar(255) NOT NULL COMMENT '邮箱',
 `password` varchar(255) NOT NULL COMMENT '密码',
 `username` varchar(255) NOT NULL COMMENT '姓名',
 PRIMARY KEY (`id`),
 UNIQUE KEY `email` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;


INSERT INTO `user` VALUES ('1', '1@qq.com', '123456', '张三');
INSERT INTO `user` VALUES ('2', '2@qq.com', '234567', '李四');
INSERT INTO `user` VALUES ('3', '3@qq.com', '345678', '王五');
```

主程序：

```java
/**
 * 主程序类
 *
//  * @SpringBootApplication：这是一个SpringBoot应用
 */
@SpringBootApplication
public class MainApplication {
   public static void main(String[] args) {
      SpringApplication.run(MainApplication.class, args);
   }
}
```

新建一个路由

```java
// @ResponseBody
// @Controller

// 这个注解集成了以上两个
@RestController
public class HelloController {
   @ResponseBody
   @RequestMapping("/hello")
   public String Handle01() {
      return "hello,spring boot";
   }
}
```

然后运行主程序，应用就运行起来了，在浏览器输入localhost:8080/hello，就能看到消息了。

## 体会

springboot相比ssm，少了很多配置，使用默认配置来简化开发。

使用父项目来引入依赖(几乎是开发中所有会用到的依赖)，项目不需要自己引入依赖了。

对父项目的依赖版本不满意，可以自己在pom.xml修改

```xml
  <!-- 也可以自己修改版本 -->
  <properties>
    <mysql.version>5.1.43</mysql.version>
  </properties>
```

集成了tomcat环境，可以打包成一个完整的项目直接运行，不需要额外配置服务器。
