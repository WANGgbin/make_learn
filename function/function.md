# 问题
- 函数语法格式
- 函数展开
- 常见的函数

# 详述
make 里面的函数是用来干什么的呢?通过转化文本来计算要操作的文件或者要执行的 recipe.
## 函数语法
`$(func arg1,arg2,...)` 函数名与参数之间通过空格分割,参数之间通过`,`分割.<br>
函数的执行顺序为:
- 通过分割符号`,`确定函数参数
- 展开函数参数
- 执行函数
之所以要强调函数的执行顺序,是因为如果参数包含一些特殊字符比如`,`的时候,不能直接在函数调用中指定.一个比较好的做法是,将这类参数包装到一个变量中,然后在函数调用语句中,引用该变量即可.eg
```sh
    comma := ,
    empty :=
    space := $(empty) $(empty) # make 中通过这种方法来定义空格
    foo := a b c
    bar := $(subst $(space),$(comma),$(foo)) # bar 结果为: a,b,c
```
## 函数展开
函数什么时候展开呢?看函数所在的位置.如果函数不在 recipe 中,则立即展开.如果在 recipe 中,只有执行 recipe 的时候才展开.

## 常见的函数
这里介绍几种比较重要的函数,其他的函数使用的时候可以参考 GNU make.
- shell
shell 函数用来执行 shell 命令. 语法为: $(shell sh command). eg:
```sh
    $(shell echo "something")
```
    shell 函数的返回结果就是 shell 命令的执行结果.但是 make 会对 shell 命令返回结果做一层简单的处理. **将换行符转化为一个空格**.
因为 shell 函数是单独拉起一个 shell 进程来执行命令的,因此在结合递归扩展变量的时候,要特别注意性能问题.避免 make 拉起过多的 shell 进程.
- foreach
    foreach 的语法为`$(foreach var,list,text)`. 遍历 list 中的每一个 word(空格分割),然后赋值给变量 var,然后执行 text(text 中会引用 var). 函数的输出为每一个输出的并集(空格分割).
- 条件函数
make 内建的条件函数有:
  - if
    语法为: `$(if condition,then-part,else-part)`
    函数的输出为 then-part 或者 else-part.
  - or
    语法为: `$(or condition1,condition2,...)`
    函数输出为第一个非空的 condition 展开结果,如果所有 condition 展开都为空,则函数返回空字符串.
  - and
    语法为: `$(and condition1,condition2,...)`
    只要有一个 condition 展开为空值,则函数返回空字符串.如果都不为空,函数返回为最后一个 condition 的展开结果.
- call
    我们通过 call 函数可以调用我们自定义的函数. call 函数的语法为 `call variable,param1,param2,...`.
第一个参数为表达式,通常将表达式至于一个变量中. 在 variable 中,可以通过 `$(1)`, `$(2)`来引用函数参数.
注意, 跟 ifdef 类似, **variable 是变量的名字而不是变量的引用**. eg: reverse 函数实现:
```sh
    reverse = $(2) $(1)
    $(call reverse,a,b) # 输出为: b a
```
- 日志函数
make 包括三类日志函数:
  - $(error text)
    除了打印日志外,终止 make 运行.
  - $(warning text)
    不会终止函数运行.
  - $(info text)
    不会终止函数运行.
**注意这类函数并没有返回值,只是将 text 输出到标准输出**.