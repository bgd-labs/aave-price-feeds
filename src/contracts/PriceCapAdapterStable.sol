// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IPriceCapAdapterStable, ICLSynchronicityPriceAdapter, IACLManager, IChainlinkAggregator} from '../interfaces/IPriceCapAdapterStable.sol';

/**
 * @title PriceCapAdapterStable
 * @author BGD Labs
 * @notice Price adapter to cap the price of the USD pegged assets
 */
contract PriceCapAdapterStable is IPriceCapAdapterStable {
  /// @inheritdoc IPriceCapAdapterStable
  int256 public constant MAX_STABLE_CAP_VALUE = 2e8;

  /// @inheritdoc IPriceCapAdapterStable
  IChainlinkAggregator public immutable ASSET_TO_USD_AGGREGATOR;

  /// @inheritdoc IPriceCapAdapterStable
  IACLManager public immutable ACL_MANAGER;

  /// @inheritdoc ICLSynchronicityPriceAdapter
  uint8 public immutable decimals;

  /// @inheritdoc ICLSynchronicityPriceAdapter
  string public description;

  int256 internal _priceCap;

  /**
   * @param capAdapterStableParams parameters to create stable cap adapter
   */
  constructor(CapAdapterStableParams memory capAdapterStableParams) {
    if (address(capAdapterStableParams.aclManager) == address(0)) {
      revert ACLManagerIsZeroAddress();
    }

    ASSET_TO_USD_AGGREGATOR = capAdapterStableParams.assetToUsdAggregator;
    ACL_MANAGER = capAdapterStableParams.aclManager;
    description = capAdapterStableParams.adapterDescription;
    decimals = ASSET_TO_USD_AGGREGATOR.decimals();

    _setPriceCap(capAdapterStableParams.priceCap);
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() external view override returns (int256) {
    int256 basePrice = ASSET_TO_USD_AGGREGATOR.latestAnswer();
    int256 priceCap = _priceCap;

    if (basePrice > priceCap) {
      return priceCap;
    }

    if (basePrice <= 0) {
      return 0;
    }

    return basePrice;
  }

  /// @inheritdoc IPriceCapAdapterStable
  function setPriceCap(int256 priceCap) external {
    if (!ACL_MANAGER.isRiskAdmin(msg.sender) && !ACL_MANAGER.isPoolAdmin(msg.sender)) {
      revert CallerIsNotRiskOrPoolAdmin();
    }

    _setPriceCap(priceCap);
  }

  /// @inheritdoc IPriceCapAdapterStable
  function getPriceCap() external view returns (int256) {
    return _priceCap;
  }

  /// @inheritdoc IPriceCapAdapterStable
  function isCapped() public view virtual returns (bool) {
    return ASSET_TO_USD_AGGREGATOR.latestAnswer() > _priceCap;
  }

  /**
   * @notice Updates price cap
   * @param priceCap the new price cap
   */
  function _setPriceCap(int256 priceCap) internal {
    if (priceCap > MAX_STABLE_CAP_VALUE || priceCap < 0) {
      revert InvalidNewPriceCap();
    }

    int256 basePrice = ASSET_TO_USD_AGGREGATOR.latestAnswer();
    if (priceCap < basePrice) {
      revert CapLowerThanActualPrice();
    }

    _priceCap = priceCap;

    emit PriceCapUpdated(priceCap);
  }
}
