// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';
import {IStETH} from '../../interfaces/IStETH.sol';
import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';

/**
 * @title TETHPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (tETH / USD) pair by using
 * @notice Price capped adapter feed for (WSTETH / ETH / USD) and (tETH / WSTETH) ratio.
 */
contract TETHPriceCapAdapter is PriceCapAdapterBase {
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
    return int256(IERC4626(RATIO_PROVIDER).convertToAssets(10 ** RATIO_DECIMALS));
  }
}
