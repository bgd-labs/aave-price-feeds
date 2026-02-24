// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IEBTC} from '../../interfaces/IEBTC.sol';

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';

/**
 * @title EBTCPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (eBTC / USD) pair by using
 * @notice Chainlink data feed for (BTC / USD) and (eBTC / BTC) ratio.
 */
contract EBTCPriceCapAdapter is PriceCapAdapterBase {
  /**
   * @param capAdapterParams parameters to create cap adapter
   */
  constructor(
    CapAdapterParams memory capAdapterParams
  )
    PriceCapAdapterBase(
      CapAdapterBaseParams({
        aclManager: capAdapterParams.aclManager,
        baseAggregatorAddress: capAdapterParams.baseAggregatorAddress,
        ratioProviderAddress: capAdapterParams.ratioProviderAddress,
        pairDescription: capAdapterParams.pairDescription,
        ratioDecimals: 18,
        minimumSnapshotDelay: capAdapterParams.minimumSnapshotDelay,
        priceCapParams: capAdapterParams.priceCapParams
      })
    )
  {}

  /// @inheritdoc IPriceCapAdapter
  function getRatio() public view override returns (int256) {
    /// @dev The eBTC ratio provider uses 8 decimal places.
    /// @dev Considering the current configuration of `maxYearlyRatioGrowthPercent`,
    /// it is necessary to add an extra precision of `1e10` to ensure that
    /// `maxRatioGrowthPerSecond` is accurately configured.
    return int256(IEBTC(RATIO_PROVIDER).getRate()) * 1e10;
  }
}
