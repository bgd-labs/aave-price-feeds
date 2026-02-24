// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IChainlinkAggregator} from './IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from './ICLSynchronicityPriceAdapter.sol';

interface IEURPriceCapAdapterStable is ICLSynchronicityPriceAdapter {
  /**
   * @notice Parameters to create eur stable cap adapter
   * @param capAdapterStableParams parameters to create eur stable cap adapter
   */
  struct CapAdapterStableParamsEUR {
    IACLManager aclManager;
    IChainlinkAggregator assetToUsdAggregator;
    IChainlinkAggregator baseToUsdAggregator;
    string adapterDescription;
    int256 priceCapRatio;
    uint8 ratioDecimals;
  }

  /**
   * @dev Emitted when the price cap ratio gets updated
   * @param priceCapRatio the new price cap ratio
   **/
  event PriceCapRatioUpdated(int256 priceCapRatio);

  /**
   * @notice Price feed for (ASSET / USD) pair
   */
  function ASSET_TO_USD_AGGREGATOR() external view returns (IChainlinkAggregator);

  /**
   * @notice Price feed for (BASE / USD) pair
   */
  function BASE_TO_USD_AGGREGATOR() external view returns (IChainlinkAggregator);

  /**
   * @notice Number of decimals of the priceCap ratio
   */
  function RATIO_DECIMALS() external view returns (uint8);

  /**
   * @notice ACL manager contract
   */
  function ACL_MANAGER() external view returns (IACLManager);

  /**
   * @notice Updates price cap ratio
   * @param priceCapRatio the new price cap ratio
   */
  function setPriceCapRatio(int256 priceCapRatio) external;

  /**
   * @notice Get price cap ratio value
   */
  function getPriceCapRatio() external view returns (int256);

  /**
   * @notice Returns if the price is currently capped
   */
  function isCapped() external view returns (bool);

  error ACLManagerIsZeroAddress();
  error CallerIsNotRiskOrPoolAdmin();
  error CapLowerThanActualPrice();
}
