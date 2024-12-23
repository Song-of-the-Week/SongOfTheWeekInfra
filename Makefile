all: install-tgenv install-tfenv install

.PHONY: install-tgenv
install-tgenv:
	git clone https://github.com/tgenv/tgenv.git ~/.tgenv
	echo 'export PATH=$$PATH:$$HOME/.tgenv/bin:$$PATH' >> ~/.bashrc

.PHONY: install-tfenv
install-tfenv:
	git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
	echo 'export PATH=$$PATH:$$HOME/.tfenv/bin' >> ~/.bashrc

.PHONY: install
install:
	tfenv install
	tgenv install