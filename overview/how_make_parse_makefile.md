# 问题
- Makefile 的执行流程是什么样的呢?
# 详述
    make 是如何解析 Makefile 的呢?
    make 的整个解析过程包括两个部分: read && execute.
    - read
    读入 Makefile 内容,并分析 target 的依赖关系.
    - execute
    确定 target,然后根据 read 阶段确定的依赖关系执行对应的命令.

    Makefile 有个很重要的概念: expand. expand 主要包括变量的展开和函数的展开.
    Makefile 中的 expand 有两种类型,在读入 Makefile 的时候就展开,这种 expand 就是 immediate.反之就是 defer expand.延后的 expand 直到执行 recipe 或者被 immediate 上下文引用时才展开.
    defer expand 这种机制似乎很奇怪,但它确实有自己的用处.一个典型的例子就是, 在一个多行变量中定义若干 command(canned(灌装) recipe), command内部引用了自动变量. 随后在 rule 中便可以引用该变量. 因为多行变量是延迟展开的(默认), 所以内部引用自动变量不会有什么问题,直到执行 rule 的时候才展开. eg:
    ```
    define log
    @echo $@
    @echo $<
    endef

    *.o: *.c
        $(log)
    ```

    > 关于 expand 的详细内容,会在介绍 variables 的时候再详述.

    make 是以行为单位解析 Makefile 的.解析一行的流程为:
    - 读入完整的一行
        这里的一行指的是逻辑行. 当一行太长的时候,为了可读性考虑,就需要写成多行的形式.Makefile 也是支持多行的,跟很多其他语言类似,通过`\`完成换行符的转义. make 在解析多行的时候,会将 '\'+'\n' 转化为一个空格,同时将'\'之前以及 '\n' 之后的空格,合并为一个空格.
    - 移除注释
        移除注释. Makefile 中的注释是通过 '#' 表示的.
    - 是否 tab 开头
        Makefile recipe 中的指令必须以 tab 开头.当一行以 tab 开头且在一个 rule 上下文中的时候, make 便认为这是一个 command.所以,**在 recipe 外,任何行都不能以 tab 开头**.
        当以 tab 开头的时候, make 并不会展开当前行,只是将其添加到 rule 对应的 recipe 中. 
    - 展开
        否则,需要展开当前行,包括变量的展开,函数的展开.
    - 执行具体的操作
      判断当前行是赋值操作还是 rule,然后执行具体的操作. **当展开变量后,就两种形式:赋值语句,rule语句**
      - 变量赋值
      - rule
# 总结
    make 执行流程整体分为两个阶段:read, execute. read 阶段是通过一行行的读入来构造依赖上下文的, execute 阶段根据 read 构造的依赖上下文来执行命令.