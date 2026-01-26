// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IChainlinkAggregator} from '../../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title StETHtoETHSynchronicityPriceAdapter
 * @author BGD Labs
 * @notice Price adapter to return a constant 1:1 price of (stETH / ETH) pair.
 */
contract StETHtoETHSynchronicityPriceAdapter is ICLSynchronicityPriceAdapter {
  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public constant DECIMALS = 18;

  string private _description;

  /**
   * @param pairName name identifier
   */
  constructor(string memory pairName) {
    _description = pairName;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function description() external view returns (string memory) {
    return _description;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function decimals() external pure returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() public view virtual override returns (int256) {
    return 1 ether;
  }
}
