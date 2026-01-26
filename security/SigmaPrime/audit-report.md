# Aave wstETH Chainlink Synchronicity Price Adapter Review

## Introduction

Sigma Prime was commercially engaged to perform a time-boxed security review of the Aave Chainlink Synchronicity Price Adapter smart contracts, as part of the [Master Services Agreement](https://governance.aave.com/t/sigma-prime-security-assessment-services-for-aave/8518) established between Sigma Prime and the Aave DAO.
The review focused on the security aspects of the Solidity smart contracts, along with the relevant migration processes.

### Disclaimer

Sigma Prime makes all effort but holds no responsibility for the findings of this security review. Sigma Prime does
not provide any guarantees relating to the function of the smart contract. Sigma Prime makes no judgements
on, or provides any security review, regarding the underlying business model or the individuals involved in the
project.

### Overview

This review covers updates to the oracle mechanisms associated with the `CLwstETHSynchronicityPriceAdapter` and `CLSynchronicityPriceAdapterBaseToPeg` contracts.
The purpose of these contracts is to reduce the impact of lag time when multiple stable coins (USD) have different price feeds.
The updated price adapters will share either a Base to Peg or Peg to Base price feed and have a unique Asset to Peg feed.

The Base to Peg price adapter uses two feeds to establish the price for an asset.

- Asset to Peg price (e.g. USDC to USD)
- Base to Peg price (e.g. ETH to USD)

The final calculation is:

```
(Asset to Base) = (Asset to Peg) / (Base to Peg)
```

The wstETH price adapter also uses two Chainlink feeds however the Base / Peg price is inverted.

- Asset to Peg price (e.g. stETH to ETH)
- Peg to Base price (e.g. ETH to USD)

Additionally, wstETH price adapter also uses the Lido stETH contract for the price of `wstETH / stETH`.

The final calculation is:

```
(wstETH to Base) = (stETH to ETH) * (ETH to USD) * (wstETH to stETH)
```

### Scope

The review was conducted on commit [cf40a4f](https://github.com/bgd-labs/cl-synchronicity-price-adapter/commit/cf40a4f129fff75971e4337c4c25f50c7aed1efb).

The scope of the audit covers the following components:

- `CLwstETHSynchronicityPriceAdapter.sol`
- `CLSynchronicityPriceAdapterPegToBase.sol`
- `CLSynchronicityPriceAdapterBaseToPeg.sol`

### Summary of Findings

One miscellaneous finding was found during the review posing negligible security risks.

## Miscellaneous

### M1. Incorrect Documentation Around Chainlink Feeds

The following comment is found in `CLwstETHSynchronicityPriceAdapter.sol` on line #13.

```
@notice Chainlink Data Feeds for (wstETH / ETH) and (ETH / USd) pairs and (wstETH / stETH) ratio.
```

The comment is invalid as the correct feeds should be `(stETH / ETH) and (ETH / USD) pairs and (wstETH / stETH) ratio`.
Such that the outcome of multiplying each of these would be `wstETH / USD`.

**Recommendations**

Update the comments to reflect the correct Chainlink pairs.
