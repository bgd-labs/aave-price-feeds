# How to Add a New CAPO Adapter

This guide covers adding price cap adapters for LST, stablecoin, or Pendle PT assets.

**Before you start:** Contact risk providers for CAPO parameters:

- **LST**: `maxYearlyGrowthPercent` and `minimumSnapshotDelay`
- **Stablecoin**: fixed cap value
- **Pendle PT**: `maxDiscountRatePerYear` and `discountRatePerYear`

---

## LST Adapter

### 1. Create Adapter (if needed)

#### Option A: Native exchange rate

If the LST contract provides a native rate method:

1. Add interface to [`/src/interfaces/`](/src/interfaces/). Examples:
   - [`IWeEth.sol`](/src/interfaces/IWeEth.sol)—`getRate()` on
     [token contract](https://etherscan.io/token/0xcd5fe23c85820f7b72d0926fc9b05b43e359b7ee#readProxyContract#F8)
   - [`IOsTokenVaultController.sol`](/src/interfaces/IOsTokenVaultController.sol)—`convertToAssets()` on
     [vault controller](https://etherscan.io/address/0x2a261e60fb14586b474c208b1b7ac6d0f5000306#readContract#F3)
2. Add adapter to [`/src/contracts/lst-adapters/`](/src/contracts/lst-adapters/).
   Inherit from [`PriceCapAdapterBase`](/src/contracts/PriceCapAdapterBase.sol) and implement `getRatio()`.

#### Option B: Chainlink rate feed

Use the generic [`CLRatePriceCapAdapter`](src/contracts/CLRatePriceCapAdapter.sol)—no new contract needed.

### 2. Get Snapshot Parameters

Risk providers give you growth rate and minimum snapshot delay, but you need `snapshotRatio` and `snapshotTimestamp`:

1. Use [GetExchangeRatesTest](tests/utils/GetExchangeRatesTest.t.sol):
   - Add a method to get the rate for the corresponding network (see [sUSDe example](tests/utils/GetExchangeRatesTest.t.sol#L69))
   - Set block number to approximately `now - minimumSnapshotDelay in blocks`; (tip: you can check blocks per day in [BlockUtils.sol](tests/utils/BlockUtils.sol))
   - Run test with console output to obtain the rate `snapshotRatio` and timestamp `snapshotTimestamp`

### 3. Deploy

Add deployment function to the network script (e.g., [`DeployEthereum.s.sol`](scripts/DeployEthereum.s.sol)):

| Parameter                     | Description                                                  |
| ----------------------------- | ------------------------------------------------------------ |
| `aclManager`                  | ACL manager of the pool                                      |
| `baseAggregatorAddress`       | Base asset feed (e.g., `ETH/USD` for ETH-based LSTs)         |
| `ratioProviderAddress`        | Contract providing exchange ratio (native or Chainlink feed) |
| `pairDescription`             | Adapter description (e.g, `capped rsETH / ETH / USD`)        |
| `minimumSnapshotDelay`        | From risk provider (typically 7 or 14 days)                  |
| `snapshotRatio`               | Exchange ratio at snapshot time                              |
| `snapshotTimestamp`           | Timestamp of snapshot                                        |
| `maxYearlyRatioGrowthPercent` | From risk provider                                           |

> **zkSync:** Return encoded parameters instead of deployment code.

Use the Makefile deploy target: `make deploy adapter=<AdapterName> chain=<chain>` (example: `make deploy adapter=WeEth chain=mainnet`).

### 4. Test

1. 1. Add/update the adapter test file in `tests/adapters/` (append new network test contracts to the existing file when possible).
2. Inherit from [`BaseTest`](tests/BaseTest.sol) and implement `_createAdapter()`,
   or use [`CLAdapterBaseTest`](tests/CLAdapterBaseTest.sol) for Chainlink-based adapters
3. Configure test parameters:
   - Adapter code
   - Retrospective days (default: 90)
   - Fork parameters (network, block) (tip: use the `now` block you used to obtain the snapshot block)
   - Report name `{asset}_{network}` (e.g., `sUSDe_Ethereum`)

> **zkSync:** Add `salt` parameter: `new CLRatePriceCapAdapter{salt: 'test'}(params)`

---

## Stablecoin Adapter

Use existing [`PriceCapAdapterStable`](src/contracts/PriceCapAdapterStable.sol)—no new contract needed.

### 1. Deploy

Add deployment function to the network script:

| Parameter              | Description                                   |
| ---------------------- | --------------------------------------------- |
| `aclManager`           | ACL manager of the pool                       |
| `assetToUsdAggregator` | `Asset/USD` feed address                      |
| `adapterDescription`   | Adapter description                           |
| `priceCap`             | Cap value (e.g., `int256(1.04 * 1e8)` for 4%) |

Use the Makefile deploy target: `make deploy adapter=<AdapterName> chain=<chain>` (example: `make deploy adapter=USDC chain=mainnet`).

### 2. Test

Inherit from [`BaseStableTest`](tests/BaseStableTest.sol) and specify deployment code, retrospective days, and fork parameters.

---

## Pendle PT Adapter

For Pendle Principal Tokens (PT) that trade at a discount decaying linearly to zero at maturity.

Use existing [`PendlePriceCapAdapter`](src/contracts/PendlePriceCapAdapter.sol)—no new contract needed.

**Before you start:** Contact risk providers for:

- `maxDiscountRatePerYear`: Maximum allowed discount rate
- `discountRatePerYear`: Current discount rate

### 1. Deploy

Add deployment function to the network script:

| Parameter                | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `aclManager`             | ACL manager of the pool                                |
| `assetToUsdAggregator`   | Underlying asset feed (e.g., `USDT/USD`)               |
| `pendlePrincipalToken`   | PT token contract address                              |
| `maxDiscountRatePerYear` | From risk provider (e.g., `27.9e16` for 27.9%)         |
| `discountRatePerYear`    | From risk provider (e.g., `8.52e16` for 8.52%)         |
| `description`            | Adapter description (e.g., `PT Capped sUSDe USDT/USD`) |

> Maturity is read automatically from the PT token contract.

Use the Makefile deploy target: `make deploy adapter=<AdapterName> chain=<chain>` (example: `make deploy adapter=PendlePt chain=mainnet`).

---

## Synchronicity Adapters

When capping an asset not pegged to the pool's base currency (e.g., `agEUR` against `EUR` instead of `USD`), combine adapters:

1. Cap adapter for `agEUR/EUR`
2. [`CLSynchronicityPriceAdapterPegToBase`](src/contracts/CLSynchronicityPriceAdapterPegToBase.sol) to combine with `EUR/USD` feed → capped `agEUR/USD`

See [example script](scripts/Example.s.sol).
