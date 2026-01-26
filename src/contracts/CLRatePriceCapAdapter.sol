// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';

import {PriceCapAdapterBase, IPriceCapAdapter} from './PriceCapAdapterBase.sol';

/**
 * @title CLRatePriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (lstASSET / USD) pair by using
 * @notice Chainlink data feeds for (ASSET / USD) and (lstASSET / ASSET).
 */
contract CLRatePriceCapAdapter is PriceCapAdapterBase {
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
        ratioDecimals: IChainlinkAggregator(capAdapterParams.ratioProviderAddress).decimals(),
        minimumSnapshotDelay: capAdapterParams.minimumSnapshotDelay,
        priceCapParams: capAdapterParams.priceCapParams
      })
    )
  {}

  /// @inheritdoc IPriceCapAdapter
  function getRatio() public view override returns (int256) {
    return IChainlinkAggregator(RATIO_PROVIDER).latestAnswer();
  }
}
