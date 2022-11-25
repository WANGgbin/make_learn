.ONESHELL: print
print:
	@echo hello
	@echo world

export SHELL = /bin/bash
get_default_shell:
	@echo $(SHELL)
	@cd sub_dir && $(MAKE) -f sub.mk