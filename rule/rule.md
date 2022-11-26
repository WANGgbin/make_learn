# 详述
## PHONY target
什么是 PHONY target 呢? PHONY 意为"假的". 在 make 中, target 通常为一个文件,这里的假就是相对于文件而言,也就是"不是文件"的意思.
- 为什么要有 PHONY
  那为什么要有 PHONY 呢?主要是避免文件冲突,保证 recipe 总会执行.考虑下面例子:
  ```sh
    clean:
        rm -rf *.o
  ```
  一般情况下,上面 recipe 总会执行. 可是如果存在一个`clean`的文件,因为上述 target 没有 prerequisites,因此 clean 会被认为是最新的,因此就不会执行 recipe.因此
  需要将 clean 设置为 .PHONY target 的 prerequisites. **注意 ".PHONY" 是个特殊的 target.**
  ```sh
    .PHONY: clean
    clean:
        rm -rf *.o
  ```
  另一个使用 PHONY 的原因是, 隐式规则的搜寻并不会应用到 .PHONY 对象上.
- 经典使用手法
  在一个大型的 Makefile 中,会有很多的 PHONY target,重复的声明会比较麻烦.一个好的实践是,声明一个名为 PHONY 的变量.凡是要声明为 .PHONY target 依赖的 target, 都可以追加到
  这个变量中.在 Makefile 中,加入一句 `.PHONY: $(PHONY)` 即可.
  ```sh
    PHONY :=
    target1:
        ...
    PHONY += target1
    target2:
        ...
    PHONY += target2
    ...
    .PHONY: $(PHONY)
  ```
- 注意
  特别需要注意的是, 如果一个 pattern 被设置为 PHONY target. make 会把该 pattern 视为一个 literal.因此对于 pattern target, 如果要保证总是运行可以使用 **FORCE** 机制.
## 没有 prerequisites 或者 recipe 的 rule
make 有这样一条规则,如果一个 rule 没有 prerequisites 或者 recipe, 而且 target 并不是一个存在的文件. 当这个 rule 运行完毕后, make 总会认为 target 被更新了.  因此所有依赖于此类 target 的 target 的 recipe 总是会执行. eg:
```sh
    clean: FORCE
        rm -rf *.f
    FORCE: # 总是被 make 认为是最新的, 这也是 FORCE 在 make 中的常用方法.
```
对于 pattern rule, 我们可以通过这种方式,保证 recipe 总是运行.
什么时候,我们会定义这样的一个看似很奇怪的 rule 呢?
## 一些特殊的内建的 targets
- .PHONY
- .DEFAULT
- .ONESHELL
- .IGNORE
  定义为 .IGNORE 依赖的 target, 在执行其 recipe 的时候,如果发生错误,会被忽略. 如果我们显示的定一个空 prerequisites 的 .IGNORE, Mkefile 中所有的 recipe 的错误都会被忽略.等价于 命令行中指定 `--ignore-errors`.

## 静态模式(static pattern rule)
静态模式规则的语法为:
```sh
    targets: target-pattern: prerequisites-pattern
        recipe
```
根据 target 来构造 prerequisites. 要特别注意, **targets 里面的所有 target 必须都要符合 target-pattern, 否则会发出警告**.
make 中还有一个称为模式规则(pattern rule)的语法. 跟静态模式规则的区别是什么呢?
个人理解是应用范围的区别.如果只是某几个target 有相似的 rule 可以使用 静态模式规则. 如果某一 pattern 的所有 target 都有相似的 rule, 则可以使用 pattern rule.
另外需要注意的是 make 中的模式匹配规则. 当一个字符串跟 pattern 匹配的时候,会先取出字符串中`/`之前的内容,使用剩下的内容跟 pattern 匹配,提取 % 对应的内容. 当根据此 % 生成字符串的时候,是相反的过程.
先替代 % 对应的内容,然后在生成的内容前加上 / 以及之前的内容. eg:
```sh
    a.%.o: b.%.c
        $(CC) -o $@ -c $<
```
如果一个 target 为 `dir1/dir2/a.xxx.o` 则对应的 prerequisites 为: `dir1/dir2/b.xxx.c`. 如果一个 target 匹配多个 pattern 的时候,使用粒度最细的 pattern.

## 文件的搜寻目录
搜寻机制使得当 rule 中的文件所在的路径发生变化的时候,我们不需要修改 rule,只需要修改搜寻目录即可.因此: **不建议在 rule 中使用相对路径指定文件**.
- VPATH
 可以使用 VPATH 变量指定 make 的搜寻目录. 当文件在当前目录找不到的时候, make 会搜寻 VPATH 中定义的目录.
 VPATH 中的目录通过`:`分隔. eg:
 ```sh
    VPATH = src:../headers
 ```
- vpath
  使用 vpath 可以给一些特定的文件指定搜寻目录.语法为:
```sh
    # 指定目录
    vpath pattern directories
    # 取消目录
    vpath pattern
    # 取消所有的目录
    vpath
```
    如果一个文件匹配多个 vpath pattern 的时候,则按照 vpath 在 Makefile 中定义的顺序来搜寻.
- make 目录搜寻规则
  make 通过目录搜寻机制找到的路径有可能是会被丢弃的. 当一个文件在其他目录中找到的时候, 如果该文件作为一个 target,则根据是否 rebuilt 有两种可能.
  - rebuilt
    如果需要 rebuilt 的话,则找到的文件会被丢弃.按照 rule 在当前目录下重新生成一个文件.
  - not rebuilt
    如果不需要 rebuilt 的话,则找到的文件被保留.
可以通过使用环境变量`GPATH`来改变 rebuilt 场景下的行为. 即使需要 rebuilt,只要文件所在的目录在 `GPATH` 中,则仍使用找的文件. `GPATH`的内容同 `VPATH`.

- write recipes with directory search
  特别需要注意的是,在我们书写 recipe 的时候需要考虑 directory search 机制.否则 recipe 会发生意料之外的错误. eg:
  - 不考虑 directory search
    ```sh
        foo.o: foo.c
            $(CC) -o foo.o -c foo.c
    ```
    如果 foo.c 是在其他目录发现的,则执行 recipe 的时候就找不到 foo.c.
  - 考虑 directory search
    ```sh
        foo.o: foo.c
            $(CC) -o $@ -c $^
    ```
    这里使用了自动变量,即使 foo.c 在其他目录, 自动变量跟随目录发现.