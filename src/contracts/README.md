# Price Cap Adapters

This folder contains the core price cap adapter contracts. For usage instructions, see [how-to.md](/how-to.md).

## PriceCapAdapterBase (LSTs)

Abstract base contract for Liquid Staking Tokens (wstETH, rETH, weETH, etc.) that grow in value over time.

### How It Works

The adapter caps prices based on a maximum allowed growth rate:

1. Stores a **snapshot ratio** and **timestamp** of the LST/underlying exchange rate
2. Calculates a **maximum allowed ratio** based on configured yearly growth percentage
3. If current ratio exceeds the cap, returns the capped value

```text
maxRatio = snapshotRatio + (maxGrowthPerSecond × timeSinceSnapshot)

if (currentRatio > maxRatio) return maxRatio
else return currentRatio
```

### Parameters

| Parameter                     | Description                                    |
| ----------------------------- | ---------------------------------------------- |
| `snapshotRatio`               | Exchange ratio at snapshot time                |
| `snapshotTimestamp`           | When the snapshot was taken                    |
| `maxYearlyRatioGrowthPercent` | Maximum allowed growth in bps (e.g., 500 = 5%) |
| `minimumSnapshotDelay`        | Minimum age of snapshot (typically 7-14 days)  |

### Design Considerations

- **Precision**: Maximum precision is not the objective. The cap has sufficient margin,
  and Aave's risk parameters provide additional protection.

- **Safety checks**: Basic validation is applied, but since access is controlled by trusted entities
  (Aave governance), checks are not exhaustive. Additional layers (e.g., Risk Stewards) provide extra limitations.

- **Snapshot timing**: Timestamps should not decrease between updates. The `MINIMUM_SNAPSHOT_DELAY` prevents issues
  from discrete ratio updates in LSTs—if a snapshot is taken just before a ratio update,
  the calculated growth rate would be artificially high.

- **MAXIMUM_SNAPSHOT_TERM**: Snapshots cannot be older than 180 days to ensure parameters stay current.

- **Internal conversion**: Yearly bps are converted to per-second growth rate internally for gas efficiency.
  Yearly bps format is exposed externally for consistency with other Aave systems.

### Extending

Each LST has unique characteristics. Inherit from `PriceCapAdapterBase` and implement `getRatio()`
to fetch the current exchange rate. See [lst-adapters/](./lst-adapters/) for examples.

---

## PriceCapAdapterStable (Stablecoins)

Simplified adapter for USD-pegged stablecoins without growth component.

### How It Works

```text
if (oraclePrice > priceCap) return priceCap
else return oraclePrice
```

### Parameters

| Parameter              | Description                                     |
| ---------------------- | ----------------------------------------------- |
| `priceCap`             | Maximum allowed price (e.g., 1.04e8 for 4% cap) |
| `MAX_STABLE_CAP_VALUE` | Hard limit of 2e8 (200%)                        |

---

## PendlePriceCapAdapter (PT Tokens)

Adapter for Pendle Principal Tokens using linear discount decay model.

### How It Works

PT tokens trade at a discount that decreases linearly to zero at maturity:

```text
currentDiscount = (maturity - now) × discountRatePerYear / SECONDS_PER_YEAR
PT_price = assetPrice × (1 - currentDiscount)
```

### Parameters

| Parameter                | Description                                |
| ------------------------ | ------------------------------------------ |
| `discountRatePerYear`    | Current discount rate (e.g., 0.05e18 = 5%) |
| `maxDiscountRatePerYear` | Maximum allowed discount rate              |
| `maturity`               | Read from PT token contract                |

---

## Synchronicity Adapters

Combine two Chainlink feeds to derive a third price pair.

| Adapter                                        | Formula                             | Use Case                    |
| ---------------------------------------------- | ----------------------------------- | --------------------------- |
| `CLSynchronicityPriceAdapterBaseToPeg`         | (Asset/USD) / (ETH/USD) = Asset/ETH | Get ETH-denominated price   |
| `CLSynchronicityPriceAdapterPegToBase`         | (Asset/ETH) × (ETH/USD) = Asset/USD | Get USD price from ETH pair |
| `FixedRatioSynchronicityPriceAdapterBaseToPeg` | Fixed ratio × (Base/Peg)            | Discounted price pairs      |

### Requirements

- For `BaseToPeg`: both input feeds must have equal decimals
- Output price is calculated with up to 18 decimals
