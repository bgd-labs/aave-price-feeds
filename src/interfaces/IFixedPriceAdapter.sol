// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IACLManager} from 'aave-address-book/AaveV3.sol';

interface IFixedPriceAdapter {
  /**
   * @dev Emitted when the fix price cap is updated by the POOL_ADMIN
   * @param currentPrice the current fixed price of the feed
   * @param newPrice the new fixed price of the feed
   */
  event FixedPriceUpdated(int256 currentPrice, int256 newPrice);

  /**
   * @notice Number of decimals in the output of this price feed
   */
  function DECIMALS() external view returns (uint8);

  /**
   * @notice ACL manager contract
   */
  function ACL_MANAGER() external view returns (IACLManager);

  /**
   * @notice Sets new fixed price
   * @dev Method could called only by the POOL_ADMIN
   * @param newPrice the new fixed price to set
   */
  function setPrice(int256 newPrice) external;

  /**
   * @notice Hardcoded price of the price feed
   * @return int256 price
   */
  function price() external view returns (int256);

  /**
   * @notice Returns the description of the feed
   * @return string description
   */
  function description() external view returns (string memory);

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

  error ACLManagerIsZeroAddress();
  error CallerIsNotPoolAdmin();
  error InvalidPrice();
}
