// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDiscountedMKRSKYAdapter} from '../../interfaces/IDiscountedMKRSKYAdapter.sol';
import {IBasicFeed} from '../../interfaces/IBasicFeed.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {
  IChainlinkAggregator
} from 'cl-synchronicity-price-adapter/interfaces/IChainlinkAggregator.sol';

/**
 * @title DiscountedMKRSKYAdapter
 * @author BGD Labs
 * @notice Price adapter to calculate MKR price based on SKY price, a fixed exchange rate, and a configurable discount.
 *         Designed for the Aave v3 protocol to be used during the active MKR to SKY migration.
 *
 * @dev Price Formula:
 *      MKR_price = SKY_price * EXCHANGE_RATE * (1 - discount)
 *
 *      Implementation:
 *      ((referenceFeedPrice * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - discount)) / (ONE_HUNDRED_PERCENT_BPS * ONE_EXCHANGE_RATE)
 *
 *      Parameters:
 *      - referenceFeed: Chainlink-compatible oracle for SKY/USD price
 *      - EXCHANGE_RATE: Fixed MKR/SKY conversion rate with 2 decimal precision (immutable)
 *        e.g., 24000_00 means 24000 SKY = 1 MKR
 *      - discount: Percentage discount in BPS, configurable by Pool Admin
 *        e.g., 6_00 = 6% discount
 *
 *      Example:
 *      - SKY/USD price: $0.0665 (6650503 with 8 decimals)
 *      - Exchange rate: 24000 (24000_00 with 2 decimals)
 *      - Discount: 6% (6_00 in BPS)
 *      - Result: (6650503 * 2400000 * 9400) / 1000000 = ~$1500 (150035347680 with 8 decimals)
 *
 *      Immutable (set at deployment):
 *      - DECIMALS (taken from reference feed), ACL_MANAGER, EXCHANGE_RATE, description
 *
 *      Configurable by Pool Admin:
 *      - discount: via setDiscount()
 *      - referenceFeed: via setReferenceFeed()
 *
 *      Assumptions:
 *      - Reference feed decimals == REQUIRED_DECIMALS (8) - validated on set
 *      - Reference feed price > MIN_REFERENCE_PRICE - validated on set
 *      - If reference price <= 0 at query time, returns 0 (Aave handles that case)
 */
contract DiscountedMKRSKYAdapter is IDiscountedMKRSKYAdapter {
  /// @dev Minimum discount in BPS (0.1%)
  uint256 public constant MIN_DISCOUNT = 10;
  /// @dev Maximum discount in BPS (99.9%)
  uint256 public constant MAX_DISCOUNT = 99_90;
  /// @dev Represents 1:1 exchange rate with 2 decimal precision (1_00 = 1.00)
  uint256 public constant ONE_EXCHANGE_RATE = 1_00;
  /// @dev Represents 100% in BPS (100_00 = 100%)
  uint256 public constant ONE_HUNDRED_PERCENT_BPS = 100_00;
  /// @dev Minimum valid reference price (0.00001 with 8 decimals)
  int256 public constant MIN_REFERENCE_PRICE = 1000;
  /// @dev Required decimals for reference feed (must be exactly 8)
  uint8 public constant REQUIRED_DECIMALS = 8;

  /// @inheritdoc IBasicFeed
  uint8 public immutable DECIMALS;

  IACLManager public immutable ACL_MANAGER;

  /// @dev Discount applied to reduce the final MKR price, in BPS
  /// Valid range: [MIN_DISCOUNT, MAX_DISCOUNT] (0.1% to 99.9%)
  uint256 public discount;

  /// @dev Fixed MKR/SKY exchange rate with 2 decimal precision (immutable)
  /// e.g., 24000_00 means 1 MKR = 24000 SKY
  uint256 public immutable EXCHANGE_RATE;

  /// @dev Chainlink-compatible price feed for SKY/USD
  IChainlinkAggregator public referenceFeed;

  /// @inheritdoc IBasicFeed
  string public description;

  constructor(
    address aclManager_,
    uint256 discount_,
    address referenceFeed_,
    uint256 exchangeRate_,
    string memory description_
  ) {
    if (aclManager_ == address(0)) revert ACLManagerIsZeroAddress();
    if (exchangeRate_ < ONE_EXCHANGE_RATE) revert InvalidExchangeRate();

    ACL_MANAGER = IACLManager(aclManager_);
    EXCHANGE_RATE = exchangeRate_;
    description = description_;
    _setDiscount(discount_);
    _setReferenceFeed(referenceFeed_);
    DECIMALS = IChainlinkAggregator(referenceFeed_).decimals();
  }

  /// @inheritdoc IBasicFeed
  function decimals() external view returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc IBasicFeed
  function latestAnswer() external view virtual returns (int256) {
    int256 rawPrice = referenceFeed.latestAnswer();

    // This should never happen, but as extra validation
    if (rawPrice <= 0) return 0;

    // forge-lint: disable-next-line(unsafe-typecast)
    uint256 referenceFeedPrice = uint256(rawPrice);

    // e.g. (6650503 * 24000_00) * (100_00 - 6_00) / (100_00 * 1_00) = 150035347680 (~$1500 with 8 decimals)
    // Safe to cast as final price will always fit into int256
    // forge-lint: disable-next-line(unsafe-typecast)
    return
      int256(
        ((referenceFeedPrice * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - discount)) /
          (ONE_HUNDRED_PERCENT_BPS * ONE_EXCHANGE_RATE)
      );
  }

  /// @notice Updates the discount applied to the MKR price
  /// @param newDiscount New discount in BPS (must be between MIN_DISCOUNT and MAX_DISCOUNT)
  function setDiscount(uint256 newDiscount) external {
    if (!ACL_MANAGER.isPoolAdmin(msg.sender)) revert CallerIsNotPoolAdmin();
    _setDiscount(newDiscount);
  }

  /// @notice Updates the reference price feed
  /// @param newReferenceFeed New Chainlink-compatible feed address (must return price >= MIN_REFERENCE_PRICE)
  function setReferenceFeed(address newReferenceFeed) external {
    if (!ACL_MANAGER.isPoolAdmin(msg.sender)) revert CallerIsNotPoolAdmin();
    _setReferenceFeed(newReferenceFeed);
  }

  function _setDiscount(uint256 newDiscount) internal {
    if (newDiscount < MIN_DISCOUNT || newDiscount > MAX_DISCOUNT) revert InvalidDiscount();
    uint256 currentDiscount = discount;
    discount = newDiscount;

    emit DiscountUpdated(currentDiscount, newDiscount);
  }

  function _setReferenceFeed(address newReferenceFeed) internal {
    if (newReferenceFeed == address(0)) {
      revert InvalidFeed();
    }

    IChainlinkAggregator feed = IChainlinkAggregator(newReferenceFeed);

    if (feed.decimals() != REQUIRED_DECIMALS) revert InvalidDecimals();

    if (feed.latestAnswer() < MIN_REFERENCE_PRICE) revert PriceTooLow();

    address currentReferenceFeed = address(referenceFeed);
    referenceFeed = feed;

    emit ReferenceFeedUpdated(currentReferenceFeed, newReferenceFeed);
  }
}
