# 这里特别注意 utils.c 文件的路径, 如果直接写为 utils.c, 那么外部 Makefile 在执行的时候,会报 utils.c 找不到的错误.
utils.o: ./sub_dir/utils.c
	gcc -o $@ -c $^