# 问题
- include 机制是什么样的
- 什么场景下应该使用 include directive
- 使用 include 的时候,需要注意什么
# 总结
- include 机制是什么样的
    include 机制的目的就是为了复用.将一些重复的内容,写到一个单独的 Makefile 中.其他的 Makefile 只需要 include 该文件即可.
- 什么场景下应该使用 include directive
    常见的使用场景为:如果当前需要 build 多个程序,而且每个程序对应的 Makefile 位于不同的目录中. 这些 Makefile 需要一些相同的变量定义或者 rule,那么我们就可以
    把这部分内容提取到一个单独的 Makefile 中,然后咋其他 Makefile 中引用该文件内容即可.
- 使用 include 的时候,需要注意什么
    - 我们知道, make 的执行流程分为两个阶段:read, execute. 在 read 阶段,如果需要 include directive, 就暂停当前文件的读取,转而去读取被 include 的文件,
    当被 include 的文件读取完毕之后,再继续 main Makefile 的读取. 本质上 include 就是文本的替换.特别需要注意的是: 被 include 文件的解析是在 main Makefile
    的上下文环境进行的. 一个经典的例子是当前工作目录.这意味这,在子 Makefile 中,当前工作目录也是 main Makefile 所在的目录而不是 子Makeifle 所在的目录.
    eg:
    参考 how_to_use_include.make/sub_dir/Makefile 中 utils.c 文件路径的指定.

    - 当 include 子 Makefile 的时候,如果找不到对应的 Makefile 会报错.如果想忽略这种错误,可以在 include 前面加上'-'. 
    - 找寻子Makefile 文件的目录
        如果是相对目录,默认在当前目录寻找 Makefile,如果找不到,则在命令行参数'-I'或者'--include-dir'指定的目录中寻找,如果还找不到,则会尝试以下目录:
        - /usr/local/include
        - /usr/include
        include 搜索目录定义在变量'.INCLUDE_DIRS'中. eg:
        ```
        print:
            @echo $(.INCLUDE_DIRS)

        输出:
            /usr/include /usr/local/include

        如果,通过以下方式运行 make:
        make --include-dir .
        则输出为:
        . /usr/include /usr/local/include
        ```