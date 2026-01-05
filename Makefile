# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes
test   :; forge test -vvv

# Common
common-flags := --ledger --mnemonic-indexes $(MNEMONIC_INDEX) --sender $(LEDGER_SENDER) --verify -vvvv --broadcast --slow
deploy-pk := --sender $(SENDER) --private-key ${PRIVATE_KEY} --verify -vvvv --slow --broadcast

# Deploy
deploy-teth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployTETHEthereum --rpc-url mainnet $(common-flags)
deploy-weeth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployWeEthEthereum --rpc-url mainnet $(common-flags)
deploy-usde-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployUSDeEthereum --rpc-url mainnet $(common-flags)
deploy-weeth-arbitrum :; forge script scripts/DeployArbitrumWeEth.s.sol:DeployWeEthArbitrum --rpc-url arbitrum $(common-flags)
deploy-weeth-scroll :; forge script scripts/DeployScroll.s.sol:DeployWeEthScroll --rpc-url scroll $(common-flags)
deploy-weeth-base :; forge script scripts/DeployBase.s.sol:DeployWeEthBase --rpc-url base $(deploy-pk)
deploy-syrupusdc-base :; forge script scripts/DeployBase.s.sol:DeploySyrupUSDCBase --rpc-url base $(deploy-pk)

deploy-oseth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployOsEthEthereum --rpc-url mainnet $(common-flags)

deploy-ethx-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployEthXEthereum --rpc-url mainnet $(common-flags)

deploy-susde-mainnet :; forge script scripts/DeployEthereum.s.sol:DeploySUSDeEthereum --rpc-url mainnet $(common-flags)

deploy-susds-mainnet :
	forge script scripts/DeployEthereum.s.sol:DeployUSDSEthereum --rpc-url mainnet $(common-flags)
	forge script scripts/DeployEthereum.s.sol:DeploysUSDSEthereum --rpc-url mainnet $(common-flags)

deploy-wsteth-bnb :; forge script scripts/DeployBnb.s.sol:DeployWstEthBnb --rpc-url bnb $(common-flags)

deploy-bnbx-bnb :; forge script scripts/DeployBnb.s.sol:DeployBNBxBnb --rpc-url bnb $(common-flags)

deploy-ezeth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployEzEthEthereum --rpc-url mainnet $(common-flags)

deploy-sdai-mainnet :; forge script scripts/DeployEthereum.s.sol:DeploySDaiEthereum --rpc-url mainnet $(common-flags)
deploy-sdai-gnosis :; forge script scripts/DeployGnosis.s.sol:DeploySDaiGnosis --rpc-url gnosis $(common-flags)

deploy-rseth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployRsEthEthereum --rpc-url mainnet $(common-flags)
deploy-rseth-arbitrum :; forge script scripts/DeployArbitrum.s.sol:DeployRsETHArbitrum --rpc-url arbitrum $(common-flags)
deploy-rseth-base :; forge script scripts/DeployBase.s.sol:DeployRsETHBase --rpc-url base $(common-flags)

deploy-rseth-avalanche :; forge script scripts/DeployAvalanche.s.sol:DeployWrsETHeAvalanche --rpc-url avalanche $(common-flags)
deploy-ausd-avalanche :; forge script scripts/DeployAvalanche.s.sol:DeployAUSDAvalanche --rpc-url avalanche $(common-flags)
deploy-susde-avalanche :; forge script scripts/DeployAvalanche.s.sol:DeploySUSDeAvalanche --rpc-url avalanche $(common-flags)

deploy-weeth-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployWeEthLinea --rpc-url linea $(common-flags)
deploy-ezeth-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployEzEthLinea --rpc-url linea $(common-flags)
deploy-usdc-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployUSDCLinea --rpc-url linea $(common-flags)
deploy-usdt-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployUSDTLinea --rpc-url linea $(common-flags)
deploy-wsteth-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployWstETHLinea --rpc-url linea $(common-flags)
deploy-wrseth-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployWRstETHLinea --rpc-url linea $(common-flags)

deploy-musd-linea :; FOUNDRY_PROFILE=linea forge script scripts/DeployLinea.s.sol:DeployMUSDLinea --rpc-url linea $(common-flags)
deploy-musd-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployMUSDEthereum --rpc-url mainnet $(common-flags)

deploy-fixed-musd-linea :; forge script scripts/DeployLinea.s.sol:DeployFixedMUSDLinea --rpc-url linea $(common-flags)
deploy-fixed-musd-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployFixedMUSDEthereum --rpc-url mainnet $(common-flags)

deploy-fixed-usdg-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployFixedUSDGEthereum --rpc-url mainnet $(common-flags)

deploy-weETH-zksync :; forge script --zksync scripts/DeployZkSync.s.sol:DeployWeEthZkSync --rpc-url zksync $(common-flags)
deploy-sUSDe-zksync :; forge script --zksync scripts/DeployZkSync.s.sol:DeploySUSDeZkSync --rpc-url zksync $(common-flags)
deploy-USDe-zksync :; forge script --zksync scripts/DeployZkSync.s.sol:DeployUSDeZkSync --rpc-url zksync $(common-flags)

deploy-eurc-base :; forge script scripts/DeployBase.s.sol:DeployEURCBase --rpc-url base $(common-flags)

deploy-eurc-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployEURCEthereum --rpc-url mainnet $(common-flags)

deploy-rlusd-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployRLUSDEthereum --rpc-url mainnet $(common-flags)
deploy-usdtb-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployUSDtbEthereum --rpc-url mainnet $(common-flags)

deploy-pt-susde-31-jul-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtSUSDe31JUL2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-susde-25-sep-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtSUSDe25SEP2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-susde-27-nov-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtSUSDe27NOV2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-eusde-29-may-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtEUSDe29MAY2025Ethereum --rpc-url mainnet $(common-flags)

deploy-syrupUSDC-mainnet :; forge script scripts/DeployEthereum.s.sol:DeploySyrupUSDCEthereum --rpc-url mainnet $(common-flags)

deploy-eUSDe-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployEUSDeEthereum --rpc-url mainnet $(common-flags)

deploy-pt-eusde-14-aug-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtEUSDe14AUG2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-usde-31-jul-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtUSDe31JUL2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-usde-25-sep-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtUSDe25SEP2025Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-usde-27-nov-2025-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtUSDe27NOV2025Ethereum --rpc-url mainnet $(common-flags)

deploy-usdc-soneium :; forge script scripts/DeploySoneium.s.sol:DeployUSDCSoneium --rpc-url soneium $(common-flags)
deploy-usdt-soneium :; forge script scripts/DeploySoneium.s.sol:DeployUSDTSoneium --rpc-url soneium $(common-flags)

deploy-usdg-ink :; forge script scripts/DeployInk.s.sol:DeployUSDGInk --rpc-url ink $(common-flags)
deploy-usdt-ink :; forge script scripts/DeployInk.s.sol:DeployUSDTInk --rpc-url ink $(common-flags)
deploy-usdc-ink :; forge script scripts/DeployInk.s.sol:DeployUSDCInk --rpc-url ink $(common-flags)
deploy-wrseth-ink :; forge script scripts/DeployInk.s.sol:DeployWRsETHInk --rpc-url ink $(common-flags)
deploy-wsteth-ink :; forge script scripts/DeployInk.s.sol:DeployWStETHInk --rpc-url ink $(common-flags)
deploy-weeth-ink :; forge script scripts/DeployInk.s.sol:DeployWeETHInk --rpc-url ink $(common-flags)
deploy-ezeth-ink :; forge script scripts/DeployInk.s.sol:DeployEzETHInk --rpc-url ink $(common-flags)

deploy-susde-plasma :; forge script scripts/DeployPlasma.s.sol:DeploySUSDePlasma --rpc-url plasma $(common-flags)
deploy-wsteth-plasma :; forge script scripts/DeployPlasma.s.sol:DeployWstETHPlasma --rpc-url plasma $(common-flags)
deploy-weETH-plasma :; forge script scripts/DeployPlasma.s.sol:DeployWeEthPlasma --rpc-url plasma $(common-flags)
deploy-usdt-plasma :; forge script scripts/DeployPlasma.s.sol:DeployUSDTPlasma --rpc-url plasma $(common-flags)
deploy-syrupusdt-plasma :; forge script scripts/DeployPlasma.s.sol:DeploySyrupUSDTPlasma --rpc-url plasma $(common-flags)
deploy-pt-susde-15-jan-2026-plasma :; forge script scripts/DeployPlasma.s.sol:DeployPtSUSDe15JAN2026Plasma --rpc-url plasma $(common-flags)
deploy-pt-usde-15-jan-2026-plasma :; forge script scripts/DeployPlasma.s.sol:DeployPtUSDe15JAN2026Plasma --rpc-url plasma $(common-flags)
deploy-pt-susde-09-apr-2026-plasma :; forge script scripts/DeployPlasma.s.sol:DeployPtSUSDe09APR2026Plasma --rpc-url plasma $(deploy-pk)
deploy-pt-usde-09-apr-2026-plasma :; forge script scripts/DeployPlasma.s.sol:DeployPtUSDe09APR2026Plasma --rpc-url plasma $(deploy-pk)

deploy-pt-susde-05-feb-2026-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtSUSDe05FEB2026Ethereum --rpc-url mainnet $(common-flags)
deploy-pt-usde-05-feb-2026-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployPtUSDe05FEB2026Ethereum --rpc-url mainnet $(common-flags)

deploy-dpi-eth-mainnet :; forge script scripts/DeployEthereum.s.sol:DeployFixedDpiEthEthereum --rpc-url mainnet $(common-flags)
deploy-dpi-usd-polygon :; forge script scripts/DeployPolygon.s.sol:DeployFixedDpiUsdPolygon --rpc-url polygon $(common-flags)
deploy-dpi-eth-polygon :; forge script scripts/DeployPolygon.s.sol:DeployFixedDpiEthPolygon --rpc-url polygon $(common-flags)

# Utilities
download :; cast etherscan-source --chain ${chain} -d src/etherscan/${chain}_${address} ${address}
git-diff :
	@mkdir -p diffs
	@npx prettier ${before} ${after} --write
	@printf '%s\n%s\n%s\n' "\`\`\`diff" "$$(git diff --no-index --diff-algorithm=patience --ignore-space-at-eol ${before} ${after})" "\`\`\`" > diffs/${out}.md
