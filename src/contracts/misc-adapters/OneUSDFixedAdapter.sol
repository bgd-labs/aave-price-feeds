// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBasicFeed} from '../../interfaces/IBasicFeed.sol';

/**
 * @title OneUSDFixedAdapter
 * @author BGD Labs
 * @notice Price adapter returning a fixed 1 USD price with 8 decimals (Chainlink-standard)
 */
contract OneUSDFixedAdapter is IBasicFeed {
  /// @inheritdoc IBasicFeed
  uint8 public constant DECIMALS = 8;

  int256 public constant ONE_USD = 1e8;

  /// @inheritdoc IBasicFeed
  function description() external pure returns (string memory) {
    return 'ONE USD';
  }

  /// @inheritdoc IBasicFeed
  function decimals() external pure returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc IBasicFeed
  function latestAnswer() external pure returns (int256) {
    return ONE_USD;
  }
}
