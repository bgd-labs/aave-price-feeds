// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IEURPriceCapAdapterStable, ICLSynchronicityPriceAdapter, IACLManager, IChainlinkAggregator} from '../../interfaces/IEURPriceCapAdapterStable.sol';

/**
 * @title EURPriceCapAdapterStable
 * @author BGD Labs
 * @notice Price capped adapter to cap the price of the EUR asset using the
 * @notice chainlink market feeds ASSET/USD and EUR/USD
 */
contract EURPriceCapAdapterStable is IEURPriceCapAdapterStable {
  /// @inheritdoc IEURPriceCapAdapterStable
  IChainlinkAggregator public immutable ASSET_TO_USD_AGGREGATOR;

  /// @inheritdoc IEURPriceCapAdapterStable
  IChainlinkAggregator public immutable BASE_TO_USD_AGGREGATOR;

  /// @inheritdoc IEURPriceCapAdapterStable
  IACLManager public immutable ACL_MANAGER;

  /// @inheritdoc IEURPriceCapAdapterStable
  uint8 public immutable RATIO_DECIMALS;

  /// @inheritdoc ICLSynchronicityPriceAdapter
  uint8 public decimals;

  /// @inheritdoc ICLSynchronicityPriceAdapter
  string public description;

  int256 internal _priceCapRatio;

  /**
   * @param capAdapterStableParams parameters to create eur stable cap adapter
   */
  constructor(CapAdapterStableParamsEUR memory capAdapterStableParams) {
    if (address(capAdapterStableParams.aclManager) == address(0)) {
      revert ACLManagerIsZeroAddress();
    }

    ASSET_TO_USD_AGGREGATOR = capAdapterStableParams.assetToUsdAggregator;
    BASE_TO_USD_AGGREGATOR = capAdapterStableParams.baseToUsdAggregator;
    ACL_MANAGER = capAdapterStableParams.aclManager;
    RATIO_DECIMALS = capAdapterStableParams.ratioDecimals;
    description = capAdapterStableParams.adapterDescription;
    decimals = ASSET_TO_USD_AGGREGATOR.decimals();

    _setPriceCapRatio(capAdapterStableParams.priceCapRatio);
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() external view returns (int256) {
    return _latestAnswer();
  }

  /// @inheritdoc IEURPriceCapAdapterStable
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    )
  {
    uint256 timestamp = block.timestamp;
    answer = _latestAnswer();
    return (uint80(timestamp), answer, timestamp, timestamp, uint80(timestamp));
  }

  /// @inheritdoc IEURPriceCapAdapterStable
  function setPriceCapRatio(int256 priceCapRatio) external {
    if (!ACL_MANAGER.isRiskAdmin(msg.sender) && !ACL_MANAGER.isPoolAdmin(msg.sender)) {
      revert CallerIsNotRiskOrPoolAdmin();
    }

    _setPriceCapRatio(priceCapRatio);
  }

  /// @inheritdoc IEURPriceCapAdapterStable
  function getPriceCapRatio() external view returns (int256) {
    return _priceCapRatio;
  }

  /// @inheritdoc IEURPriceCapAdapterStable
  function isCapped() public view virtual returns (bool) {
    return (ASSET_TO_USD_AGGREGATOR.latestAnswer() > this.latestAnswer());
  }

  /**
   * @notice Updates price cap ratio
   * @param priceCapRatio the new price cap ratio
   */
  function _setPriceCapRatio(int256 priceCapRatio) internal virtual {
    int256 assetPrice = ASSET_TO_USD_AGGREGATOR.latestAnswer();
    int256 basePrice = BASE_TO_USD_AGGREGATOR.latestAnswer();

    if ((basePrice * priceCapRatio) / int256(10 ** RATIO_DECIMALS) < assetPrice) {
      revert CapLowerThanActualPrice();
    }

    _priceCapRatio = priceCapRatio;

    emit PriceCapRatioUpdated(priceCapRatio);
  }

  function _latestAnswer() internal view virtual returns (int256) {
    int256 assetPrice = ASSET_TO_USD_AGGREGATOR.latestAnswer();
    int256 basePrice = BASE_TO_USD_AGGREGATOR.latestAnswer();
    int256 maxPrice = (basePrice * _priceCapRatio) / int256(10 ** RATIO_DECIMALS);

    if (assetPrice > maxPrice) {
      return maxPrice;
    }

    return assetPrice;
  }
}
