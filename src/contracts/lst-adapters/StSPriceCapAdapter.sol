// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';
import {IStS} from '../../interfaces/IStS.sol';

/**
 * @title StSPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (stS / USD) pair by using
 * @notice Chainlink data feed for (S / USD) and (stS / S) ratio.
 */
contract StSPriceCapAdapter is PriceCapAdapterBase {
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
    return int256(IStS(RATIO_PROVIDER).convertToAssets(10 ** RATIO_DECIMALS));
  }
}
