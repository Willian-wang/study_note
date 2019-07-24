##MyBatis 笔记

### MyBaties启动顺序

1. 构建SqlSessionFactory
注意：SqlSessionFactory全局单例唯一。
    1. 利用Resource.getResourceAsXXX方法获得输入输出流
    2. 再通过 new SqlSessionFactory().Build(resource);获得SqlSessionFectory实例 
    对于SqlSessionFactory的构建可以通过XML和JAVA类构建 
    不过复杂的映射语句仍需要通过XML进行构建 
    从XML构建： 
```XML
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
  PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <environments default="development">
    <environment id="development">
    <!--指定为开发环境-->
      <transactionManager type="JDBC"/>
      <!--指定事务管理为JDBC-->
      <dataSource type="POOLED">
    <!--连接方式为数据库连接池-->
        <property name="driver" value="${driver}"/>
        <property name="url" value="${url}"/>
        <property name="username" value="${username}"/>
        <property name="password" value="${password}"/>
    <!-- 定义数据源 -->
    <!-- 对于数据源的定义部分
    可以指定<property resource ="config.properties"> 替换${dirver} -->
      </dataSource>
    </environment>
  </environments>
  <mappers>
    <mapper resource="org/mybatis/example/BlogMapper.xml"/>
    <!--指定mapper映射文件-->
  </mappers>
</configuration>
```


2. 通过SqlSessionFactory中获取SqlSession实例

```java
try(SqlSession session = sqlSessionFactory.openSession()){
    //your code
}
```

3. 通过获取的SqlSession获取所需数据

下面以SQL语句映射为例：
```XML
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
  <!--指定DTD构建模块-->
  <!--那么问题来了，DTD是啥？和XSD之间有什关系？-->
  <!--
  DTD是验证文档合法性的有效方法
  1. 定义元素之间的规则
  2. 元素可使用的属性
  3. 可使用的实体符号或符号规则  
  -->
  <!--
  DTD和XSD相比：
  XSD支持命名空间，提供的数据类型更多，且使用XML语法编写
  -->

<mapper namespace="org.mybatis.example.BlogMapper">
<!-- 定义命名空间 -->
<!-- 
可以看出来，命名空间格式与调用java类格式相似。
因此，我们可以直接调用Mapper接口所对应的方法。 
-->

  <select id="selectBlog" resultType="Blog">
    select * from Blog where id = #{id}
  </select>

</mapper>
```
这个就是Mapper的映射XML  
同样，也可以使用JAVA注解进行配置，上面的例子可被替换为：  
```JAVA
package org.mybatis.example;
public interface BlogMapper {
  @Select("SELECT * FROM blog WHERE id = #{id}")
  Blog selectBlog(int id);
}
```
简单的可以这么写，但是无法处理复杂的情况。 

在写完Mapper映射后在java代码中调用相应的映射，有以下两种方法：

```java

// method 1
try (SqlSession session = sqlSessionFactory.openSession()) {
  Blog blog = (Blog) session.selectOne("org.mybatis.example.BlogMapper.selectBlog", 101);
}

// method 2 Recommend
try (SqlSession session = sqlSessionFactory.openSession()) {
  BlogMapper mapper = session.getMapper(BlogMapper.class);
  // BlogMapper.class 是一个接口
  Blog blog = mapper.selectBlog(101);
}
//总的来说，方法二更好，不依赖字符串字面值，且可使用代码补全
```

在这里，就完成了对于一次简单的查询。

---

#### 要注意的地方

#### 命名空间

作用：
1. 分隔语句
2. 实现接口绑定

解析规则：
1. 完全限定名，例如：com.mypackage.MyMapper.selectAllThing
直接用于查找或使用

2. 短名称，例如：selectAllTing
需要全局唯一，若不唯一则报错；

 
#### 作用域与生命周期

主要为并发问题
依赖注入框架为线程安全，可以了解MyBatis-Spring项目。

1. SqlSessionFactoryBuilder
这个类似于一个工具人 用完就丢
用完马上回收，释放资源。

2. SqlSeesionFactory
这个要一直活着，有且只能有一个。   
应用作用域，单例模式或者静态单例模式。 

3. SQLSession
这玩意不是线程安全的，每一个应用都需要有一个实例。
最佳作用域为请求或方法作用域。  

**注意**
1. 不能让静态作用域持有SqlSession
2. 不能放进类的实例变量
3. 不能放进任何托管作用域
..

标准关闭模式
``` java
try (SqlSession session = sqlSessionFactory.openSession()) {
  // 你的应用逻辑代码
}
```

4. 映射器实例
最佳实例为方法作用域，不需要显式丢弃。

---


### 映射文件 

在这里，映射文件主要可以分为三种元素。  

#### 1.  SQL 标签  
SQL可以分为两种，CRUD 的执行语句。  
分别对应```<select><delete><update><insert>```这几个标签。  
在这里又可以使用各种各样的条件查询，拼接SQL。  

还有一种为提高SQL语句复用率的标签，对应```<sql>```。  
可以在执行语句中使用```<include ref="sql_id">```进行替换。  

这些标签下对应着各种属性在这里就不赘述了，看官方文档即可。
http://www.mybatis.org/mybatis-3/zh/sqlmap-xml.html#insert_update_and_delete

##### 需要注意的问题：
##### 1. 自动生成主键
Mybatis支持数据库自动生成的主键，需要将userGenerate属性设置为true，KeyProperty属性中指定列名。
对于不支持自动生成主键的JDBC驱动，可以在使用```<selectKey>```子标签，并在子标签中使用 ```keyProperty="id"``` 指定主键。 并且使用SQL查询的结果作为主键。   
官方实例代码：
```XML
  <selectKey keyProperty="id" resultType="int" order="BEFORE">
    select CAST(RANDOM()*1000000 as INTEGER) a from SYSIBM.SYSDUMMY1
  </selectKey>
```
注意，这个地方```order="BEFORE"```表示在数据库查询之前生成主键。Oracle在插入语句内部可能嵌入索引调用（没看懂……

##### 2. 参数与字符串替换
###### 1. #{}与的区别
\#{} 会转义
格式为：  
```#{属性, javaType=java类型,jdbcType=数据库类型，typeHandler=类型处理器，numericScale=小数点位数,mode=输入输出模式，resultMap=结果集}```

 1. 以上不能换行
 2. 一般常用的只有属性，javaType,jdbcType这三个
 3. mode和resultMap只有在存储过程的时候使用（像阿里的代码规范里，是严禁使用存储过程，就不考虑了）
 4. 大多数时候仅仅只需要指定属性名，和为空列指定jdbcType

2. ${}
${}  仅仅只是做字面上的替换  
建议不要对用户输入使用${}，可能会有SQL注入的风险

#### 2. ResultMap

感觉这是Mybatis里最牛逼的元素

感觉还是没有理解透……看官方文档吧

```constructor```用于在实例化类时，注入结果到构造方法中  
name属性，用户指定注入的参数名  
如果没有name属性，需要注意参数的顺序。  
```association```

#### 3. Cache

用来缓存SQL语句，具体见文档。  
开启只需要```<cache/>```


### 动态SQL

```<if>```   
条件查询
```<choose><otherwise>```  
类似于if···if else链  
```<where>```
```<set>```
```<when>``` 
这三个很类似，符合条件才分别机上Where，set，when三个词。

```<foreach>```
```XML
  <foreach item="item" index="index" collection="list"
      open="(" separator="," close=")">
        #{item}
  </foreach>
```
以上为实例代码，通常用于构建in

```<script>```
用于在JAVA注解中创建匿名的XML类

```<bind>```
元素可以从 OGNL 表达式中创建一个变量并将其绑定到上下文。
```XML
<select id="selectBlogsLike" resultType="Blog">
  <bind name="pattern" value="'%' + _parameter.getTitle() + '%'" />
  SELECT * FROM BLOG
  WHERE title LIKE #{pattern}
</select>
```