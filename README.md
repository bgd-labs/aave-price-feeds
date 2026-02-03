# Aave Price Feeds

Price oracle adapter smart contracts, introducing different types of range price protection on oracle feeds used by the Aave protocol.

<br>

## Notes

The contracts in this repository use the Shanghai EVM version, please check network support before deploying.

## How to add a new adapter

[Described here](/how-to.md).

## Types

### [CLSynchronicityPriceAdapterBaseToPeg](/src/contracts/CLSynchronicityPriceAdapter.sol)

- Price adapter smart contract where `ChainlinkAggregator` addresses for `Asset / USD` and `ETH / USD` are set.
- Feeds must have the same decimals value.
- Using this two feeds, it calculates the price for pair `Asset / ETH`.
- Returning price is calculated with up to 18 decimals.

### [CLSynchronicityPriceAdapterPegToBase](/src/contracts/CLSynchronicityPriceAdapterPegToBase.sol)

- Price adapter smart contract where `ChainlinkAggregator` addresses for `Asset / ETH` and `ETH / USD` are set.
- Using this two feeds, it calculates the price for pair `Asset / USD`.
- Returning price is calculated with up to 18 decimals.

### [RatioCapPriceAdapter](./src/contracts/PriceCapAdapterBase.sol)

Certain assets like LSTs (Liquid Staking Tokens) are highly correlated to an underlying, with an additional growth component on top of it, and sometimes, slashing dynamics. This initial version of an adapter for this use case adds an upper side protection.

High-level, the idea is doing periodic updates on 3 parameters: a snapshot ratio, its timestamp, and a max allowed ratio growth in yearly percentage.
Every time the price adapter is queried, it will get the current ratio of the asset/underlying and compared it with a dynamically calculated upper value of that ratio, using the previously defined parameters.
If the current ratio is above the ratio cap, the ratio cap is returned. If not, the current ratio is.

<br>

**Misc considerations**

- Maximum precision is not the objective of this implementation, as anyway, the cap is thought to have a good margin, given that the risk parameters of the Aave protocol should protect enough.
- Some basic safety checks are applied when setting parameters, but as this is access controlled to a trusted entity (e.g. Aave governance), they are not designed to be exhaustive. The idea is to build additional update layers on top of this system (e.g. Risk Stewards) to cover extra limitations.
- Timestamp of snapshots should not decrease from one parameters update to the next.
- To optimise calculations, the maximum yearly ratio growth received in yearly bps (e.g. 5_00 for 5%) is converted to ratio growth per second internally. We expose in yearly bps percentage to follow similar approach as on other Aave systems (BGD config engine), and because we believe it is more intuitive for integrations.
- Given that each asset on which to apply this adapter has its own characteristics, the base contract is `abstract` to allow the child to define its own specificities (mainly the way of calculating/fetching the current ratio).
- On construction, an extra `MINIMUM_SNAPSHOT_DELAY` is configured, indicating the minimum time (in seconds) to have passed since the snapshot ratio timestamp, and the current moment (block.timestamp). This is required because frequently, the update of the ration in a correlated asset is a "discrete" event, which causes a spike of value by time until enough time passes. E.g. if the snapshot ratio is set 1 second before the ratio was updated in an LST, 2 seconds after the increase by unit of time would be really high.

  Defining a proper value depends on specific characteristics of the correlated asset, but generally, a conservative way would be setting a long enough delay, like 7 days.

<br>

### [FixCapPriceAdapter](./src/contracts/PriceCapAdapterStable.sol)

In some cases, the relation between an underlying asset and its correlated is direct, without any type of continuous growth expected. For example, this is the case of USD-pegged stable coins, where USD is the underlying and let's say USDC is the correlated asset.

Initially we thought to model this as a sub-case of `RatioCapPriceAdapter`, with 0 ratio growth, but finally we decided to create a simplified version of the adapter, removing completely the growth component.

<br>

<br>

### Audits

[SigmaP](./security/sigmap/audit-report.md)

[Certora](./security/Certora/Certora%20Review.pdf)

### Repository History

- The original contracts of this repository were developed inside the [CL Synchronicity Price Adapter](https://github.com/bgd-labs/cl-synchronicity-price-adapter) repository.
- They were later moved and improved in the [Aave Capo](https://github.com/bgd-labs/aave-capo) repository.
- The [Aave Capo](https://github.com/bgd-labs/aave-capo) repository was later renamed to [Aave Price Feeds](https://github.com/bgd-labs/aave-price-feeds) to better reflect its purpose.

## License

Copyright © 2026, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

The default license of this repository is [BUSL1.1](./LICENSE), but all interfaces and the content of the [libs folder](./src/contracts/libs/) and [Polygon tunnel](./src/contracts/adapters/polygon/tunnel/) folders are open source, MIT-licensed.

**IMPORTANT**. The BUSL1.1 license of this repository allows for any usage of the software, if respecting the _Additional Use Grant_ limitations, forbidding any use case damaging anyhow the Aave DAO's interests.
