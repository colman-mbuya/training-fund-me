include .env
export

DEPLOY_SCRIPT=script/DeployFundMe.s.sol

### Environment Setup
.PHONY: install-dependencies
install-dependencies:
	forge install pyth-network/pyth-sdk-solidity@v2.2.0 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install cyfrin/foundry-devops@0.0.11 --no-commit

### Build Commands

.PHONY: compile
compile:
	forge compile

.PHONY: clean
clean:
	forge clean


### Local chain creation
.PHONY: persistent-local-network
persistent-local-network:
	anvil

.PHONY: persistent-sepolia-fork-network
persistent-sepolia-fork-network:
	anvil --fork-url $(SEPOLIA_RPC_URL)

### Local chain deployment and interaction

.PHONY: local-deploy
local-deploy:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(LOCAL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vv

.PHONY: local-fund
local-fund:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(LOCAL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vv

.PHONY: local-balance
local-balance:
	forge script script/Interactions.s.sol:BalanceFundMe --rpc-url $(LOCAL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vv

.PHONY: local-withdraw
local-withdraw:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(LOCAL_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vv

### Sepolia chain deployment and interaction

.PHONY: sepolia-deploy
sepolia-deploy:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --broadcast --verify

### Tests

.PHONY: run-unit-tests
run-unit-tests:
	forge test -vv