// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title CLSynchronicityPriceAdapterBaseToPeg
 * @author BGD Labs
 * @notice Price adapter to calculate price of (Asset / Base) pair by using
 * @notice Chainlink Data Feeds for (Asset / Peg) and (Base / Peg) pairs.
 * @notice For example it can be used to calculate USDC / ETH
 * @notice based on USDC / USD and ETH / USD feeds.
 */
contract CLSynchronicityPriceAdapterBaseToPeg is ICLSynchronicityPriceAdapter {
  /**
   * @notice Price feed for (Base / Peg) pair
   */
  IChainlinkAggregator public immutable BASE_TO_PEG;

  /**
   * @notice Price feed for (Asset / Peg) pair
   */
  IChainlinkAggregator public immutable ASSET_TO_PEG;

  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public immutable DECIMALS;

  /**
   * @notice Maximum number of resulting and feed decimals
   */
  uint8 public constant MAX_DECIMALS = 18;

  string private _description;

  /**
   * @param baseToPegAggregatorAddress the address of BASE / PEG feed
   * @param assetToPegAggregatorAddress the address of the ASSET / PEG feed
   * @param decimals precision of the answer
   * @param pairDescription description
   */
  constructor(
    address baseToPegAggregatorAddress,
    address assetToPegAggregatorAddress,
    uint8 decimals,
    string memory pairDescription
  ) {
    BASE_TO_PEG = IChainlinkAggregator(baseToPegAggregatorAddress);
    ASSET_TO_PEG = IChainlinkAggregator(assetToPegAggregatorAddress);

    if (decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (BASE_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();

    if (BASE_TO_PEG.decimals() != ASSET_TO_PEG.decimals()) revert DecimalsNotEqual();

    DECIMALS = decimals;
    _description = pairDescription;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function description() external view returns (string memory) {
    return _description;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function decimals() external view returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc ICLSynchronicityPriceAdapter
  function latestAnswer() external view override returns (int256) {
    int256 assetToPegPrice = ASSET_TO_PEG.latestAnswer();
    int256 baseToPegPrice = BASE_TO_PEG.latestAnswer();

    if (assetToPegPrice <= 0 || baseToPegPrice <= 0) {
      return 0;
    }

    return (assetToPegPrice * int256(10 ** DECIMALS)) / (baseToPegPrice);
  }
}
