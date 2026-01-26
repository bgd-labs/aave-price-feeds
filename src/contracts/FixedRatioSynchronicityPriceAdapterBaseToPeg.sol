// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title FixedRatioSynchronicityPriceAdapterBaseToPeg
 * @author BGD Labs
 * @notice Price adapter to calculate price of (Asset / Base) pair by using
 * @notice Chainlink Data Feed for (Base / Peg) pair and a fixed ratio for (Asset / Base).
 */
contract FixedRatioSynchronicityPriceAdapterBaseToPeg is ICLSynchronicityPriceAdapter {
  /**
   * @notice Price feed for (Base / Peg) pair
   */
  IChainlinkAggregator public immutable BASE_TO_PEG;

  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public immutable DECIMALS;

  /**
   * @notice Percent ratio of the original peg price, e.g. 95_00
   */
  int256 public immutable PRICE_RATIO;

  /**
   * @notice This is a parameter to bring the resulting answer with the proper precision.
   * @notice will be equal to 10 to the power of the sum decimals of feeds
   */
  int256 public immutable MULTIPLIER;

  /**
   * @notice Maximum number of resulting and feed decimals
   */
  uint8 public constant MAX_DECIMALS = 18;

  string private _description;

  /**
   * @param baseToPegAggregatorAddress the address of BASE / PEG feed
   * @param priceRatio Percent ratio of the original peg price, e.g. 95_00
   * @param decimals precision of the answer
   * @param pairDescription description
   */
  constructor(
    address baseToPegAggregatorAddress,
    int256 priceRatio,
    uint8 decimals,
    string memory pairDescription
  ) {
    BASE_TO_PEG = IChainlinkAggregator(baseToPegAggregatorAddress);

    if (decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (BASE_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (priceRatio <= 0 || priceRatio >= 100_00) revert RatioOutOfBounds();

    MULTIPLIER = int256(10 ** (BASE_TO_PEG.decimals() + decimals));

    PRICE_RATIO = priceRatio;
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
    int256 baseToPegPrice = BASE_TO_PEG.latestAnswer();

    if (baseToPegPrice <= 0) {
      return 0;
    }

    return (PRICE_RATIO * MULTIPLIER) / (100_00 * baseToPegPrice);
  }
}
