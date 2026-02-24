// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {IMkrSky} from '../../../src/interfaces/IMkrSky.sol';

contract MkrSkyMock is IMkrSky {
  uint256 internal _fee;
  uint256 internal _rate;

  constructor(uint256 fee_, uint256 rate_) {
    _fee = fee_;
    _rate = rate_;
  }

  function fee() external view returns (uint256) {
    return _fee;
  }

  function rate() external view returns (uint256) {
    return _rate;
  }

  function setFee(uint256 fee_) external {
    _fee = fee_;
  }

  function setRate(uint256 rate_) external {
    _rate = rate_;
  }
}
