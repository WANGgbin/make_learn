## 变量引用
make 内部通过 `$(varname)` 的方式来引用变量.变量引用的本质就是**文本替换**. 一般 make 内部的变量命名使用大写的方式. 但是,这有可能导致跟 make 内部一些特殊的变量冲突.
## 变量定义
make 包括若干种变量的定义:
- 递归变量(延迟变量) eg:<br>
    FOO = $(BAR)
    此类变量的值只有在必要的时候,才会展开,比如在 recipe line 中.
    print:
    @echo $(FOO)  # 此时, FOO 的值就会展开
    递归变量这个概念似乎很奇怪,那么什么时候会使用这个变量呢?
    一个典型的例子就是通过多行变量定以一个 canned recipe,该 recipe 内部使用自动化变量.因为在定义的时候,并不在一个 rule 的上下文中,因此自动化变量是没有意义的.但是在执行 recipe line 的
    时候,此时自动化变量有实际对应的值,这个时候再展开就不会有什么问题.变量的延迟展开,保证了 recipe line 复用的可能性.
    但是,递归变量也是有缺点的.
    - 性能问题. eg:<br>
        FOO = $(shell ...)
        这样每一次展开 FOO 的时候,都要执行一次 shell 函数.
    - 不能在变量后面追加内容<br>
        FOO = $(FOO) -O
        这会导致,变量的无限递归. make 会检测这类情况并报错.实际上,我们可以通过 += 的方式,为变量追加内容(适合于所有类型的变量).
- 简单展开变量 eg:<br>
    FOO := $(BAR)
    此类变量的值在定义的时候就展开.也就是在定义的时候,变量的值就是确定的.此类变量跟大多数编程语言中的变量定义类似.
    通常在 Makefile 中,没有特殊需求,我们都使用简单展开变量.
- 条件赋值变量<br>
    FOO ?= bar
    当变量还没有定义的时候,该赋值语句才生效.
    特别需要注意:**即使一个变量之前被设置为一个空值,也属于被定义,因此 ?= 不会生效**. eg:
    ```sh
    FOO =
    FOO ?= bar
    print:
        @echo $(FOO)
    ```
    结果输出为空.

## 变量引用的高级特性
  - 变量替换
    可以按照一定的模式替换得到一个新的变量. 类似 patsubst 函数. eg:
    ```sh
    foo := a.o b.o l.a c.o
    bar := $(foo: %.o=%.c)
    ```
    得到的 bar 值为: a.c b.c l.a c.c

## 变量追加
我们可以使用 += 该一个已经定义的变量追加内容.需要注意几点:<br>
- 如果变量还未被定义, 则 += 等价与 =
- 如果变量已经定义, += 跟随之前的 flavor(简单展开 or 递归变量)
    eg:
    ```sh
        var := value
        var += more
    ```
    var 此时的值为: value more
    ```sh
        var = $(includes) -O
        var += -pg
    ```
    var 此时的值为: $(includes) -O -pg

## override
命令行中指定的变量会覆盖 Makefile 中定义的变量.那么如果我们想在 Makefile 内部覆盖命令行中的变量,怎么操作呢?使用 `override` 即可.eg:
    override var = value
如果想给命令行定义的变量追加更多内容:
    override var += more
特别注意,**对于已经使用 override 定义的变量,后续要赋值或者追加内容,也必须要 override,否则会被忽略.因为不加 override,会被 make 认为是一个普通的变量定义,该定义会被之前的 override 覆盖**

## 定义多行变量
使用关键字 `define`, `endef` 来定义一个多行变量.常见的使用场景为定义一个命令序列,也即 `canned recipes`,用于在不同的 rule 中复用.eg:
```sh
    define var
        command1
        command2
    endef
```
默认情况下,多行变量为递归变量.上面定义等价于:
```sh
    define var =
        command1
        command2
    endef
```
当然也可以定义为立即展开变量.eg:
```sh
    define var :=
        command1
        command2
    endef
```
多行变量和普通变量在其他方面都是完全一致的.

## target-specific 变量
一般而言,我们在 Makfile 中定义的变量都是全局生效的.但是,我们可以针对不同的 target 来给一个相同的变量定义不同的值. 这类变量只在当前的 rule 上下文中生效.类似于自动变量.
定义 target 变量的语法为:
```sh
    target1 target2: var = value # 对 target1, target2 都生效
    target: prerequisites
        commands
    target2: prerequisites
        commands
```
target-specific 变量跟普通变量类似,也可以使用 override, export 等各种关键字.
另外需要注意的是, target 定义的变量,同样对该 target 依赖的 prerequisites 生效,也对 prerequisites 依赖的 prerequisites 生效....

## pattern-specific 变量
pattern-specific 变量与 target-specific 变量类似,只不过, pattern-specific 变量给所有符合 pattern 的 target 都生效.eg:
```sh
    %.o: CFLAGS = -O
```
当一个 target 匹配多个 pattern 的时候,更准确的 pattern 会被使用.eg:
```sh
    %.o: %.c
        $(CC) -c $(CFLAGS) $< -o $@
    
    %.o: CFLAGS = -g
    lib/%.o: CFLAGS = -fpic -g

    all: foo.o lib/bar.o
```
lib/bar.o 匹配的 CFLAGS = -fpic -g

## 自动变量
主要为4个自动变量.
- $@ 表示 target
- $< 表示 prerequisites
- $^ 表示第一个 prerequisite
- $* 表示 pattern 中 % 内容

## 环境变量
make 会从基于当前环境变量构造自己的变量(除了一些特殊变量: SHELL).
make 在执行命令的时候,默认会将 make 环境变量中的变量以及 make 命令行中定义的变量,导入到 recipe 的环境变量中.其他的变量,可以通过 export 来导入.
## 变量的值
有一点需要注意, 如果在变量的值中使用单引号或者双引号,会作为变量值的一部分.举个例子:
```sh
    var := " command line"
    print:
        @echo $(var) # echo " command line"
```
通常变量赋值的时候,会将开始的空格删除,如果想要保留的话,可以考虑使用 "" 定义变量的值.