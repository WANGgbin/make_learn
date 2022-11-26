# makefile 学习资料:
# 1. GNU Make https://www.gnu.org/software/make/manual/make.html#Shell-Function
# 2. <跟我一起学习 Makefile> file:///home/wgb/Desktop/CSBooks/make/Makefile.pdf
# 3. <> 
#MAKEFLAGS := $(MAKEFLAGS) --just-print

print_path:
	@echo $(var1)
	@echo $(var2)

var := a:b:c
foo := $(subst :,     ,$(var))

var1 := abc 
var2 :=			abc

ifeq ($(var1), $(var2))
$(info case assign, yes!)
endif

ifeq ($(var1) ,    $(var2) )
$(info conditional directive, yes!)
endif