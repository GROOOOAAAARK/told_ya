PHONY: under-setup--asdf under-setup--katana setup-unix contract-full contract-artifacts declare-contract deploy-contract get-contract-class run-network

# config-account: \
# 	starkli account fetch \
# 	$ACCOUNT \
# 	--rpc $NETWORK_RPC_URL \
# 	--output ~/.starkli-wallets/devnet/deployer/account.json

SHELL=/bin/bash

CONTRACT_HASH_CLASS := $(shell starkli class-hash packages/told_ya/target/dev/told_ya_ToldYa.contract_class.json)

CONTRACT_HASH_CLASS := $(shell starkli class-hash packages/told_ya/target/dev/told_ya_ToldYa.contract_class.json)

setup-unix:
	make under-setup--asdf && \
	make under-setup--katana

under-setup--asdf:
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0 && \
	echo '. "$HOME/.asdf/asdf.sh" >> .bashrc && \
	source .bashrc && \
	asdf plugin add scarb && \
	asdf install scarb 2.6.3 && \
	asdf global scarb 2.6.3 &&

under-setup--katana:
	asdf plugin add dojo https://github.com/dojoengine/asdf-dojo && \
	asdf install dojo 0.7.2 && \
	asdf global dojo 0.7.2

contract-full:
	make contract-artifacts && \
	make declare-contract &&\
	make get-contract-class &&\
	make deploy-contract

contract-artifacts:
	cd packages/told_ya && \
	scarb build && \
	cd -

declare-contract:
	starkli declare \
	--account katana \
	--rpc=$(NETWORK_RPC_URL) \
	--strk \
	packages/told_ya/target/dev/told_ya_ToldYa.contract_class.json

deploy-contract:
	make get-contract-class &&\
	starkli deploy \
	--account katana \
	--rpc $(NETWORK_RPC_URL) \
	--strk \
	$(CONTRACT_HASH_CLASS) \
	$(OWNER_ADDRESS)


get-contract-class:
	CONTRACT_HASH_CLASS=$(CONTRACT_HASH_CLASS)

run-network:
	katana
