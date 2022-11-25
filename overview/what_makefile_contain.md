# 问题
- 什么是 Make
- Makefile 有什么用?
- Makefile 包含什么内容?
- Makefile 的语法?

# 总结
- 什么是 Make
    make 是一个可执行程序,结合 Makefile,可以实现任务的自动化运行.常用于大型项目的管理.
- Makefile 有什么用?
    通过在 Makefile 指定一系列的规则,告诉 make 如何执行任务.
- Makefile 包含什么内容?
    - 变量
        变量的目的就是为了复用.
    - rule
        rule 描述了什么样的情况下,执行什么样的操作,得到什么样的结果. 是 Makefile 的核心内容.rule 的格式为:
        ```c
        targets: prerequesits
            command...
        ```
    - recipe
        recipe 是食谱的意思,其实就是 rule 中的 commands.
    - function
        make 内建了很多的函数,当然我们也可以自定义函数.
    - condition
        什么样的情况下,选择性的使用哪些语句.make 中 condition 就只有四种.
        - ifeq
        - ifneq
        - ifdef
        - ifndef
- Makefile 的语法
    Makefile 文件内部包括两种语法.可能你会奇怪,为什么会包含两种语法呢?一种是 make 自己的语法.另一种则是 shell 的语法.
    只有在 recipe 中,才可以书写 shell 语法. 因为 recipe 最终是由 SHELL 指定的 sh 运行的. make 只对 recipe 做一次很轻量的处理(expand(变量替换,函数执行等等)),然后交给 sh.
