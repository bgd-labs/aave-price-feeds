// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

contract RatioProviderMock {
  int96 public startRatio;

  int16 public yearlyGrowth;
  int32 public startTime;

  uint8 public decimals;

  int256 public constant DENOMINATOR = 1e4;

  constructor(int96 startRatio_, int16 yearlyGrowth_, uint8 decimals_) {
    startRatio = startRatio_;
    yearlyGrowth = yearlyGrowth_;
    startTime = int32(int256(block.timestamp));

    decimals = decimals_;
  }

  function set(int96 startRatio_, int16 yearlyGrowth_) public {
    startRatio = startRatio_;
    yearlyGrowth = yearlyGrowth_;
    startTime = int32(int256(block.timestamp));
  }

  function latestAnswer() public view returns (int256) {
    return
      (startRatio * (int256(block.timestamp) - startTime) * yearlyGrowth) /
      365 days /
      DENOMINATOR +
      startRatio;
  }
}
