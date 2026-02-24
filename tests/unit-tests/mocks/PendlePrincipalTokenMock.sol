// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

contract PPTMock {
  uint256 public expiry;

  constructor(uint256 expiry_) {
    expiry = expiry_;
  }

  function setExpiry(uint256 expiry_) external {
    expiry = expiry_;
  }
}
