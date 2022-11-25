# makefile 学习资料:
# 1. GNU Make https://www.gnu.org/software/make/manual/make.html#Shell-Function
# 2. <跟我一起学习 Makefile> file:///home/wgb/Desktop/CSBooks/make/Makefile.pdf
# 3. <> 
#MAKEFLAGS := $(MAKEFLAGS) --just-print
include sub_dir/Makefile
main: main.o utils.o
	gcc -o main main.o utils.o

main.o: main.c
	gcc -o main.o -c main.c

print:
	@echo $(.INCLUDE_DIRS)