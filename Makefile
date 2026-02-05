# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
install:; forge install && npm install
update:; forge update

# Build & test
build  :; forge build --sizes
test   :; make unit-tests && make adapters-tests
unit-tests   :; forge test --match-path "tests/unit-tests/*" -vvv
adapters-tests   :; forge test --match-path "tests/adapters/*" -vvv && FOUNDRY_PROFILE=zksync forge test --zksync -vvv

# Lint
lint  :; npm run lint:fix

# Deploy

## Common
common-flags := --ledger --mnemonic-indexes $(MNEMONIC_INDEX) --sender $(LEDGER_SENDER) --verify -vvvv --broadcast --slow
common-flags-pk := --sender $(SENDER) --private-key ${PRIVATE_KEY} --verify -vvvv --slow --broadcast

## Scripts: add new ones if necessary
SCRIPT_mainnet := DeployEthereum
SCRIPT_arbitrum := DeployArbitrum
SCRIPT_base := DeployBase
SCRIPT_linea := DeployLinea
SCRIPT_bnb := DeployBnb
SCRIPT_avalanche := DeployAvalanche
SCRIPT_scroll := DeployScroll
SCRIPT_mantle := DeployMantle
SCRIPT_soneium := DeploySoneium
SCRIPT_ink := DeployInk
SCRIPT_plasma := DeployPlasma
SCRIPT_megaeth := DeployMegaEth
SCRIPT_gnosis := DeployGnosis
SCRIPT_zksync := DeployZkSync

### usage: make deploy adapter=WeEth chain=mainnet
deploy:
	@if [ -z "$(adapter)" ] || [ -z "$(chain)" ]; then \
		echo "usage: make deploy adapter=WeEth chain=mainnet"; exit 1; fi
	@script="${SCRIPT_$(chain)}"; \
	if [ -z "$$script" ]; then echo "unknown chain: $(chain)"; exit 1; fi; \
	zksync_flag=""; \
	if [ "$(chain)" = "zksync" ]; then zksync_flag="--zksync"; fi; \
	echo "forge script $$zksync_flag scripts/$$script.s.sol:Deploy$(adapter) --rpc-url $(chain) $(common-flags)"; \
	forge script $$zksync_flag scripts/$$script.s.sol:Deploy$(adapter) --rpc-url $(chain) $(common-flags)

deploy-pk:
	@if [ -z "$(adapter)" ] || [ -z "$(chain)" ]; then \
		echo "usage: make deploy adapter=WeEth chain=mainnet"; exit 1; fi
	@script="${SCRIPT_$(chain)}"; \
	if [ -z "$$script" ]; then echo "unknown chain: $(chain)"; exit 1; fi; \
	zksync_flag=""; \
	if [ "$(chain)" = "zksync" ]; then zksync_flag="--zksync"; fi; \
	echo "forge script $$zksync_flag scripts/$$script.s.sol:Deploy$(adapter) --rpc-url $(chain) $(common-flags-pk)"; \
	forge script $$zksync_flag scripts/$$script.s.sol:Deploy$(adapter) --rpc-url $(chain) $(common-flags-pk)


# Utilities
download :; cast source --chain ${chain} -d src/etherscan/${chain}_${address} ${address}
git-diff :
	@mkdir -p diffs
	@npx prettier ${before} ${after} --write
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --diff-algorithm=patience --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md
