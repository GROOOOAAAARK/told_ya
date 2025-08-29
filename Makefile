PHONY: under-setup--asdf under-setup--katana setup-unix contract-full contract-declare-deploy contract-artifacts declare-contract deploy-contract get-contract-class run-network contract-abi

SHELL=/bin/bash

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

under-setup--starkli: # Install starkli and setup for zsh
	curl https://get.starkli.sh | sh && \
	echo . /Users/thomas_grk/.starkli/env >> .zshenv && \
	source .zshenv && \
	starkliup

under-setup--katana:
	asdf plugin add dojo https://github.com/dojoengine/asdf-dojo && \
	asdf install dojo 0.7.2 && \
	asdf global dojo 0.7.2

contract-full:
	make contract-artifacts && \
	make declare-contract &&\
	make get-contract-class &&\
	make deploy-contract

contract-declare-deploy:
	make declare-contract &&\
	make get-contract-class &&\
	make deploy-contract

contract-artifacts:
	cd packages/told_ya && \
	scarb build && \
	cd -

contract-abi:
	starkli abi packages/told_ya/target/dev/told_ya_ToldYa.contract_class.json > packages/told_ya/target/dev/told_ya_ToldYa.abi.json

declare-contract:
	starkli declare \
	--account katana \
	--rpc=$(NETWORK_RPC_URL) \
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
	katana --http.cors_origins "http://localhost:3000"

# Contract Interactions

get_events:
	sncast call \
	--contract-address $(CONTRACT_ADDRESS) \
	--function get_events \
	--url $(NETWORK_RPC_URL) \
	--calldata "0x746573745f6576656e74" "0x30312f30312f32303236" "0x30322f30312f32303236" "0x666f6f7462616c6c"
