// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

contract ACLManagerMock {
  address public poolAdmin;
  address public riskAdmin;

  constructor(address poolAdmin_, address riskAdmin_) {
    poolAdmin = poolAdmin_;
    riskAdmin = riskAdmin_;
  }

  function isPoolAdmin(address admin) external view returns (bool) {
    return admin == poolAdmin;
  }

  function isRiskAdmin(address admin) external view returns (bool) {
    return admin == riskAdmin;
  }
}
