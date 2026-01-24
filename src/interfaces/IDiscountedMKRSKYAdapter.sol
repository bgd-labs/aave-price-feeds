// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBasicFeed} from './IBasicFeed.sol';
import {
  IChainlinkAggregator
} from 'cl-synchronicity-price-adapter/interfaces/IChainlinkAggregator.sol';

/**
 * @title IDiscountedMKRSKYAdapter
 * @author BGD Labs
 * @notice Interface for the DiscountedMKRSKYAdapter price feed
 */
interface IDiscountedMKRSKYAdapter is IBasicFeed {
  /// @notice MKR/SKY exchange rate (24000, meaning 1 MKR = 24000 SKY). Cached from MkrSky.rate() at deployment.
  function EXCHANGE_RATE() external view returns (uint256);

  /// @notice MkrSky migration contract on Ethereum that provides the dynamic fee/discount
  function DISCOUNT_PROVIDER() external view returns (address);

  /// @notice Current discount applied to reduce the final MKR price
  /// @dev Dynamically fetched from DISCOUNT_PROVIDER. Returns raw fee where 1e18 = 100%
  function discount() external view returns (uint256);

  /// @notice Chainlink SKY/USD price feed on Ethereum (constant)
  function REFERENCE_FEED() external view returns (IChainlinkAggregator);
}
