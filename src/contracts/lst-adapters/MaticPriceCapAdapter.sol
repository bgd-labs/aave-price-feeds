// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IMaticRateProvider} from '../../interfaces/IMaticRateProvider.sol';

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';

/**
 * @title MaticPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (lst Matic / USD) pair by using
 * @notice Chainlink data feed for (MATIC / USD) and (lst Matic / MATIC) ratio.
 * @notice can be used as it is for stMatic and MaticX on Polygon network
 */
contract MaticPriceCapAdapter is PriceCapAdapterBase {
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
    return int256(IMaticRateProvider(RATIO_PROVIDER).getRate());
  }
}
