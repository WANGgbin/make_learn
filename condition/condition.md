make 支持条件表达式.条件表达式的语法为:
```sh
    conditional-one
    text-if-one-is-true
    else conditional-two
    text-if-two-is-true
    else
    text-if-one-and-two-are-false
    endif
```
make 共支持四种条件表达式.分别为:`ifeq`, `ifneq`, `ifdef`, `ifndef`.<br>
对于条件表达式,需要注意几点:
- 关键字与条件之间要有空格
- 条件表达式的执行是在 make 的第一阶段.
- 在 recipe 中使用条件表达式,必须置于行首,否则会被 make 传递给 sh.

对于`ifdef`需要注意几点:
- ifdef 的参数是变量名而不是变量引用.如果是变量引用,则需要 expand 确定最终要测试的变量名.
- ifdef 仅仅用来测试一个变量是不是有值.并不会展开变量去判断值是不是空.因此,下面两种变量在 ifdef 看来,结果是不相同的.<br>
  - 
  ```sh
    foo =  # make 看来没有值
  ```
  - 
  ```sh
    var =
    foo = $(var) # make 看来有值,但是并不会展开判断值是不是空
  ```