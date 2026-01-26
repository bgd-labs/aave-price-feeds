// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';
import {IStETH} from '../../interfaces/IStETH.sol';
import {PriceCapAdapterBase, IPriceCapAdapter} from '../PriceCapAdapterBase.sol';

/**
 * @title TETHPriceCapAdapter
 * @author BGD Labs
 * @notice Price capped adapter to calculate price of (tETH / USD) pair by using
 * @notice Chainlink data feed for (ETH / USD) and (tETH / WSTETH / ETH) ratio.
 */
contract TETHPriceCapAdapter is PriceCapAdapterBase {
  address public constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

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
    uint256 tETHToWstETH = IERC4626(RATIO_PROVIDER).convertToAssets(10 ** RATIO_DECIMALS);
    return int256(IStETH(STETH).getPooledEthByShares(tETHToWstETH));
  }
}
