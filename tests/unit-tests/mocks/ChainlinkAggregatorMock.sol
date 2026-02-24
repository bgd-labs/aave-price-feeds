// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IChainlinkAggregator} from '../../../src/interfaces/IPriceCapAdapter.sol';

contract ChainlinkAggregatorMock is IChainlinkAggregator {
  int256 public latestAnswer;
  uint8 internal _decimals;

  constructor(int256 latestAnswer_) {
    latestAnswer = latestAnswer_;
    _decimals = 8;
  }

  function setLatestAnswer(int256 latestAnswer_) external {
    latestAnswer = latestAnswer_;
  }

  function setDecimals(uint8 decimals_) external {
    _decimals = decimals_;
  }

  function getAnswer(uint256) external view returns (int256) {
    return latestAnswer;
  }

  function getTimestamp(uint256) external view returns (uint256) {
    return block.timestamp;
  }

  function latestTimestamp() external view returns (uint256) {
    return block.timestamp;
  }

  function latestRound() external pure returns (uint256) {
    return 0;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }
}
