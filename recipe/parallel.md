# 问题
- make recipe 的运行是串行的还是并行发的.如果更改呢?

# 详述
    默认情况下, make 中的 recipe 是串行的. 我们可以通过 make 的命令行参数 --jobs=N 来更改并行策略.如果没有指定 N,则不限制并发数.
    需要注意的是,在 sub_make 场景下, 主 make 并不会将该参数直接透传给 sub_make, 因为这会导致实际的并发数超过 --jobs 指定的值.
    实际上, 主 make 和 sub_make 会一些协商,使得总共的并发数不会超过 --jobs 指定的值. 不过,如果并没有限制并发数的话,比如 --jobs,
    那么该参数会透传给 sub_make.

    eg:
    当我们以 'make all --jobs=2' 运行 paraller.mk 的时候,就会看到同时有两个 sleep 进程.

    > 注意: 串行/并行的粒度是 recipe/rule 而不是 recipe line(command).

    just for test
