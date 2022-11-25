# make 递归调用
    当构造系统复杂的时候,可以考虑将大系统拆分为多个子系统.每个子系统分别包含一个自己的 Makefile. 然后在主 Makefile 中通过调用 sub_make 来完成各个子系统的构造.
    为了方便用户, make 内部会定义一个特殊变量 `CURDIR`,表示 make 的当前工作目录. 这个变量比较特殊,有几点需要注意的地方:
    - 即使环境变量中有同名的变量, make 内部的 CURDIR 也不会继承环境变量中的值.
    - CURDIR 并不会随着 include 语句发生任何变化
    - 即使我们在 Makefile 内部修改了 CURDIR 的值,也不会对 make 的运行产生任何影响.
    - CURDIR 要么是当前目录,要么通过 make 命令行参数 -C 决定
## MAKE 变量如何工作
    通常在 recipe 中执行 sub_make 的时候,都**建议使用 $(MAKE)**,因为 $(MAKE)表示的是当前的 make,这样能保证在 sub_make 中,也是相同的 make 程序.否则在 sub_shell 中,可能会使用其他版本或者其他与主 Makefile 不一样的 make,从而产生奇怪的错误.
    另外一个需要注意的地方是,使用 $(MAKE) 变量的 recipe line,改变了 make 一些命令行参数的特性.比如: --touch, --just-print, --question. 比如,对于 --just-print,仅仅打印要执行的命令.如果对于包含 $(MAKE) 的recipe line 也只是打印命令的话,则无法深入到 sub_make 中去.因此,仍然会执行这些命令.
## 变量传递
    make 内部的变量跟环境变量有什么关系呢?
    实际上,在 make 运行的最开始,会从当前的环境变量复制出一份内部变量(当然会有一些特殊的情况,比如 SHELL, CURDIR 变量就不会集成自环境变量). 同时,会从 make 行参数中获取定义的变量.组成 make 内部的变量集合.
    在 make 内部,我们认为就只有 make 内部变量,没有环境变量这个概念.
    在执行 sub_make 的时候, make 内部的变量怎么传递给 sub_make 呢? 还是通过环境变量的方式.
    默认情况下, make 只会传递命令行参数和原始的环境变量到 sub_shell 中,如果想要传递 make 内部的其他变量,则可以使用类似于 shell 导出的语法: export. 
    ```sh
    var = value
    export var
    or
    export var = value
    ```
    当 sub_shell 运行 sub_make 的时候,站在 sub_make 角度看,无非就是一些环境变量而已,至于 sub_make 内部的变量定义则使用前面所述的方式.
    此外,需要注意,环境变量值的展开,是在执行拉起 sub_shell 的时候才展开的.
    这里要注意一个特殊的变量 `MAKELEVEL`, 此变量表示当前 make 的运行层级. 在运行 sub_make 的时候, make 会自动更改该变量的值: + 1.
## make 选项传递
    在执行 sub_make 的时候,原始 make 的命令行选项是如何传递给 sub_make 的呢?
    make 的命令行参数有三个来源: 命令行参数指定, MAKEFLAGS 环境变量, Makefile 内部更改 MAKEFLAGS 变量的值.
    比如:
    - 先导入环境变量: export MAKEFLAGS=--jobs=1
    - 创建 option.mk:
        print:
            @echo $(MAKEFLAGS)
    - 以以下方式运行 make:
        make --just-print -f option.mk
    - 输出结果为:
        echo n -j1
    
    实际上, make 就是通过环境变量 MAKEFLAGS 来传递命令行参数给 sub_make 的.
    需要注意的时,有一些特殊的选项并不会注入到 MAKEFLAGS 中: -C, -f, -o, -W.
    如果不想传递任何的命令行参数可以使用以下的两种方指定:
    - subsystem:
        cd subdir && $(MAKE) MAKEFLAGS=
    - subsystem:
        export MAKEFLAGS=; cd subdir && $(MAKE)