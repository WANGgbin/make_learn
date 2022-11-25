# recipe 语法
    Makefile 中存在这两种语法.一种是 make 语法,另一种是 shell 语法. Makefile 中大多数地方都是 make 语法,只有在 recipe 中,才使用 sh 语法.因为 recipe 是交由 sh 来执行的, make 只会对
recipe 进行一层很简单的翻译.
    recipe 中的命令必须以`tab`开头,除了跟在 target-and-prerequisites 行之后的第一行命令,通过 `;` 与 target-and-prerequisites 分割.<br>
    eg:<br>
    ```c
    target: prerequisites; comand
        comand
        ...
    ```
    recipe 的一些总结:
    - recipe 中的注释并不是 make 的注释,同样会被传递给 sh. 至于如何处理取决于 sh 的具体行为.
    - 在 recipe 中**以 tab 开头**的变量定义,并不是 make 的变量定义,同样传递给 sh.
    - 在 recipe 中**以 tab 开头**的条件表达式(ifdef, ifeq),也不会被认为是 make 一部分,同样传递给 sh. **这意味这,如果要在 recipe 中使用 make 的 条件表达式,一定不能以 tab 开头**

## recipe 中行拆分
    在 Makefile 中同样会有两种"单行拆分为多行"的情况.一种是在 recipe 之外,被视为是 make 的一部分.仅仅将 `\` + '\n' 视为一个空格同时跟前后的空格合并为一个空格.而在 recipe 中的 '\' + '\n',
    make 并不会处理这种情况,而是会将 '\' + '\n' 连接着的多行(**如果行以 tab 开头,则会先移除 tab**),直接传递给 sh,至于如何处理,取决于 sh.默认情况下,在 sh 中,'\' + '\n' 会被视为一个 "",即空字符,只是将相邻的两行串联起来. eg: <br>
    ```c
    all:
        @echo no\
    space
        @echo no\
        space   # tab 移除
        @echo one \
        space  # tab 移除
        @echo one\
         space # tab 移除
    ```
    输出为:
    ```c
    nospace
    nospace
    one space
    one space
    ```
    在 recipe 中书写多行的命令的时候,建议都以 tab 开头,这样可读性更好.
## recipe 中使用变量
    在 recipe 中使用变量的时候,需要特别注意的地方是,你要使用的是 make 变量还是 shell 变量.
    如果使用的 make 变量的话,语法同 Makefile 中其他地方.但是如果要使用 shell 变量的话,就必须采用以下方式: `$$var` 或者 `$${var}`. 之所以使用两个 $,是为了转义 $. eg: <br>
    ```c
    LIST = one two three
    all:
        for i in $(LIST); do \
            echo $$i; \
        done
    ```
    会被 make 转化为:
    ```sh
    for i in one two three; do \
        echo $i; \
    done
    ```
    最后的执行结果为:
    ```c
    one
    two
    three
    ```