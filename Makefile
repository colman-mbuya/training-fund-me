include .env
export

DEPLOY_SCRIPT=script/DeployFundMe.s.sol

### Environment Setup
.PHONY: install-dependencies
install-dependencies:
	forge install pyth-network/pyth-sdk-solidity@v2.2.0 && forge install foundry-rs/forge-std@v1.5.3

### FORGE COMMANDS

.PHONY: compile
compile:
	forge compile

.PHONY: local-deploy
local-deploy:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(LOCAL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

.PHONY: sepolia-deploy
sepolia-deploy:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify

### Tests

.PHONY: run-unit-tests
run-unit-tests:
	forge test -vv