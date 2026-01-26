// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IChainlinkAggregator} from '../../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title RepFixedPriceAdapter
 * @author BGD Labs
 * @notice Price adapter that returns calculated average price for REP / ETH
 * based on the values from 01/09/2023 till 31/10/2023
 */
contract RepFixedPriceAdapter is ICLSynchronicityPriceAdapter {
  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public constant DECIMALS = 18;

  /**
   * @notice Description price adapter
   */
  string public constant DESCRIPTION = 'REP / ETH';

  /**
   * @notice Calculated price
   */
  int256 public constant PRICE = 462569569300000;

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function description() external pure returns (string memory) {
    return DESCRIPTION;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function decimals() external pure returns (uint8) {
    return DECIMALS;
  }

  /*
   * @dev Price adapter that returns calculated average price for REP / ETH
   * based on the values from 01/09/2023 till 31/10/2023
   */
  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() public view virtual override returns (int256) {
    return PRICE;
  }
}
