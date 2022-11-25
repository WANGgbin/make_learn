# recipe 错误
    在 recipe 中,如果想要忽略某个 recipe line 的错误,则只要在这一行前加上特殊前缀字符 `-` 即可.
    如果想要在整个 makefile 的粒度忽略错误,则可以通过命令行参数 `-i` 或者 `--ignore-errors`, 或者在 Makefile 中定义一个空 prerequisites 的特殊 target: .IGNORE
