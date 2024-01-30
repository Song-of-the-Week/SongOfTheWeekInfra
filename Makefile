.PHONY: install-tgenv
install-tgenv:
	git clone https://github.com/cunymatthieu/tgenv.git ~/.tgenv
	echo 'export PATH=$$PATH:$$HOME/.tgenv/bin:$$PATH"' >> ~/.bash_profile

.PHONY: install-tfenv
install-tfenv:
	git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
	echo 'export PATH=$$PATH:$$HOME/.tfenv/bin' >> ~/.bash_profile
	
install:
	install-tgenv
	install-tfenv