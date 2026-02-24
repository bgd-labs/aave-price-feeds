# Misc Adapters

Specialized price adapters for unique use cases that don't fit the standard LST or stablecoin patterns.

| Adapter                                                                            | Purpose                               | Price Source                               |
| ---------------------------------------------------------------------------------- | ------------------------------------- | ------------------------------------------ |
| [`DiscountedMKRSKYAdapter`](./DiscountedMKRSKYAdapter.sol)                         | MKR price during SKY migration        | SKY/USD × exchangeRate × (1 - discount)    |
| [`EURPriceCapAdapterStable`](./EURPriceCapAdapterStable.sol)                       | EUR-pegged stablecoins with ratio cap | Asset/EUR feed with configurable cap ratio |
| [`FixedPriceAdapter`](./FixedPriceAdapter.sol)                                     | Hardcoded updatable price             | Admin-set fixed value                      |
| [`OneUSDFixedAdapter`](./OneUSDFixedAdapter.sol)                                   | Always returns $1.00                  | Constant 1e8                               |
| [`RepFixedPriceAdapter`](./RepFixedPriceAdapter.sol)                               | REP token fixed price                 | Constant value                             |
| [`StETHtoETHSynchronicityPriceAdapter`](./StETHtoETHSynchronicityPriceAdapter.sol) | stETH/ETH 1:1 peg                     | Constant 1e18                              |

## DiscountedMKRSKYAdapter

Calculates MKR price based on SKY price with dynamic discount from MkrSky migration contract.

```text
MKR_price = SKY_price × EXCHANGE_RATE × (1 - discount)
```

- `EXCHANGE_RATE`: 24000 (1 MKR = 24000 SKY), cached from MkrSky contract
- `discount`: Dynamic fee from MkrSky contract (1e18 = 100%)

## EURPriceCapAdapterStable

For EUR-pegged stablecoins (e.g., agEUR). Uses ratio cap relative to EUR/USD price:

```text
maxPrice = EUR_USD_price × priceCapRatio
if (assetPrice > maxPrice) return maxPrice
```

## FixedPriceAdapter

Returns a fixed price that can be updated by pool admin. Used for assets without reliable oracle feeds.

## OneUSDFixedAdapter

Immutable adapter returning exactly $1.00 (1e8 with 8 decimals). Implements `latestRoundData()` for Chainlink compatibility.

## RepFixedPriceAdapter

Returns a fixed REP/ETH price based on historical average. Used for legacy REP token pricing.

## StETHtoETHSynchronicityPriceAdapter

Returns constant 1:1 price for stETH/ETH pair (1e18). Used when stETH is assumed to be pegged to ETH.
