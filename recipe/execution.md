# 问题
- make 在执行 recipe 的时候,每一个 recipe command 会拉起一个 shell 还是整个 recipe 对应一个 shell.
- make 使用的是哪个 sh 呢?
# 详述
  - 默认情况下, make 会为每一个 recipe line 拉起一个 shell. 这一点特别需要注意. 不过,我们可以通过指定特殊 target: .ONESHELL 使得 make 为每一个 recipe 只拉起一个 shell.
    当使用 .ONESHELL 的时候,需要注意两点:
    - 只有第一行的特殊前缀字符,决定了 recipe line 的行为.
    - 其他行的特殊前缀字符在交由 shell 运行前也会被去除.eg:
    ```c
    .ONESHELL:
    print:
        echo hello  # 第一行决定了, make 会回显命令
        @echo world # 虽然含有特殊前缀,也会被去除
    ```
   当我们运行 `make print` 的时候,输出结果为:
   ```c
   echo hello
   echo world
   hello
   world
   ```
   - 错误提示<br>
    当指定 .ONESHELL 的时候,默认情况下,只有最后一个命令执行错误的时候, make 才认为发生错误.这其实不是 make 的特性,而是 sh 的特性. 在 sh 内部,可以通过 set -e 或者在 sh 命令行参数中设置 -e 来改变
    这种默认行为,使得只要有一条命令执行失败,便不再往下执行. 在 Makefile 中,传递给 sub_shell 的命令行参数是通过变量 `SHELLFLAGS` 指定的.因此,我们可以通过以下方式来改变 sh 默认行为,使得只要有一行命令执行错误,便退出 shell 不再继续运行:
    ```c
    .ONESHELL:
    SHELLFLAGS = -e
    target:
        reicpe line
        ...
    ```
  - 如何指定 make 使用的 shell 呢<br>
    默认情况下, make 会从 makefile 内部定义的 SHELL 变量(**该变量并不会继承自环境变量中的 SHELL**))获取 sh.如果没有定义该变量的话,默认是`/bin/sh`.这里有个问题,为什么不直接使用环境变量中的 SHELL 呢?
    这是因为,通常 shell 中的 SHELL 可能是用户自定义的,如果直接使用该 SHELL,可能会导致非预期的行为.
    当执行 recipe line 的时候,我们在 makefile 中指定的 SHELL 并不会传递到 sub_shell 的环境变量中,默认还是将当前环境变量中的 SHELL 传递给 sub_shell. 不过,我们可以在 Makefile 内部通过 export SHELL 的方式,将 Makefile 内部的 SHELL 传递到 sub_shell 的环境变量中. 不过, **在 sub_make 中, 使用哪个 sh, 还是通过 sub_makefile 内部定义的 SHELL 决定**.

    just for test
    some new change
    some new change
