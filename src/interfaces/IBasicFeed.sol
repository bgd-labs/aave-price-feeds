// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBasicFeed {
  /**
   * @notice Returns the description of the feed
   * @return string description
   */
  function description() external view returns (string memory);

  /**
   * @notice Returns the feed decimals (for tooling compatibility)
   * @return uint8 decimals
   */
  function DECIMALS() external view returns (uint8);

  /**
   * @notice Returns the feed decimals
   * @return uint8 decimals
   */
  function decimals() external view returns (uint8);

  /**
   * @notice Returns the fixed hardcoded price of the feed
   * @return int256 latestAnswer
   */
  function latestAnswer() external view returns (int256);
}
