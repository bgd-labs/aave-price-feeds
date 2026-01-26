// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBasicFeed} from '../../interfaces/IBasicFeed.sol';
import {IExtendedFeed} from '../../interfaces/IExtendedFeed.sol';

/**
 * @title OneUSDFixedAdapter
 * @author BGD Labs
 * @notice Price adapter returning a fixed 1 USD price with 8 decimals (Chainlink-standard)
 */
contract OneUSDFixedAdapter is IExtendedFeed {
  int256 public constant ONE_USD = 1e8;

  /// @inheritdoc IBasicFeed
  function description() external pure returns (string memory) {
    return 'ONE USD';
  }

  /// @inheritdoc IBasicFeed
  function DECIMALS() public pure returns (uint8) {
    return 8;
  }

  /// @inheritdoc IBasicFeed
  function decimals() external pure returns (uint8) {
    return DECIMALS();
  }

  /// @inheritdoc IBasicFeed
  function latestAnswer() public pure returns (int256) {
    return ONE_USD;
  }

  /// @inheritdoc IExtendedFeed
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
    uint256 ts = block.timestamp;
    // The roundId (and answeredInRound) concept in this type of "static" feed is unapplicable,
    // so returning explicitly zero to indicate it should not be consumed
    return (0, latestAnswer(), ts, ts, 0);
  }
}
