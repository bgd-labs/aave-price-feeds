// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMkrSky {
  function fee() external view returns (uint256);
  function rate() external view returns (uint256);
}
