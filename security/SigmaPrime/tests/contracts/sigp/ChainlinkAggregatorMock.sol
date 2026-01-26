pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../../interfaces/IChainlinkAggregator.sol';

/**
 * Mock contract which implements `IChainlinkAggregator`
 */
contract ChainlinkAggregatorMock is IChainlinkAggregator {
  int256 public mockAnswer;
  uint256 public mockRound;
  uint8 public mockDecimals = 8;

  constructor(int256 answer, uint256 round) {
    mockAnswer = answer;
    mockRound = round;
  }

  // IChainlinkAggregator functions

  function decimals() external view returns (uint8) {
    return mockDecimals;
  }

  function latestAnswer() external view returns (int256) {
    return mockAnswer;
  }

  function latestTimestamp() external view returns (uint256) {
    return block.timestamp;
  }

  function latestRound() external view returns (uint256) {
    return mockRound;
  }

  function getAnswer(uint256 roundId) external view returns (int256) {
    return mockAnswer;
  }

  function getTimestamp(uint256 roundId) external view returns (uint256) {
    return block.timestamp;
  }

  // Setters

  function setAnswer(int256 answer) external {
    mockAnswer = answer;
  }

  function setRound(uint256 round) external {
    mockRound = round;
  }

  function setDecimals(uint8 newDecimals) external {
    mockDecimals = newDecimals;
  }
}
