// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice A simple version of the StakedLBTCOracle interface allowing to get exchange ratio with BTC
interface ILBTC {
  function getRate() external view returns (uint256);
}
