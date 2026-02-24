// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMaplePool {
  /**
   *  @dev Returns the amount of exit assets for the input amount.
   *  @param shares_ The amount of shares to convert to assets.
   *  @return assets_ Amount of assets able to be exited.
   */
  function convertToExitAssets(uint256 shares_) external view returns (uint256 assets_);
}
