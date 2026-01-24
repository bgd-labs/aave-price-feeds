// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IBasicFeed} from './IBasicFeed.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {IChainlinkAggregator} from 'cl-synchronicity-price-adapter/interfaces/IChainlinkAggregator.sol';

/**
 * @title IDiscountedMKRSKYAdapter
 * @author BGD Labs
 * @notice Interface for the DiscountedMKRSKYAdapter price feed
 */
interface IDiscountedMKRSKYAdapter is IBasicFeed {
  /// @notice Constructor parameters for DiscountedMKRSKYAdapter
  /// @param aclManager ACL manager contract for access control
  /// @param discount Initial discount in BPS (e.g., 6_00 = 6%)
  /// @param referenceFeed Chainlink-compatible price feed for SKY/USD
  /// @param exchangeRate Fixed MKR/SKY exchange rate with 2 decimal precision (e.g., 24000_00 = 24000:1)
  /// @param description Human-readable description of the adapter
  struct ConstructorParams {
    address aclManager;
    uint256 discount;
    address referenceFeed;
    uint256 exchangeRate;
    string description;
  }
  /// @notice Emitted when the discount is updated
  /// @param currentDiscount Previous discount in BPS
  /// @param newDiscount New discount in BPS
  event DiscountUpdated(uint256 currentDiscount, uint256 newDiscount);

  /// @notice Emitted when the reference feed is updated
  /// @param currentReferenceFeed Previous feed address
  /// @param newReferenceFeed New feed address
  event ReferenceFeedUpdated(
    address indexed currentReferenceFeed,
    address indexed newReferenceFeed
  );

  /// @notice ACL manager contract for access control
  function ACL_MANAGER() external view returns (IACLManager);

  /// @notice Fixed MKR/SKY exchange rate with 2 decimal precision
  /// @dev e.g., 24000_00 means 1 MKR = 24000 SKY
  function EXCHANGE_RATE() external view returns (uint256);

  /// @notice Current discount applied to reduce the final MKR price, in BPS
  function discount() external view returns (uint256);

  /// @notice Chainlink-compatible price feed for SKY/USD
  function referenceFeed() external view returns (IChainlinkAggregator);

  /// @notice Updates the discount applied to the MKR price
  /// @param newDiscount New discount in BPS (must be between MIN_DISCOUNT and MAX_DISCOUNT)
  function setDiscount(uint256 newDiscount) external;

  /// @notice Updates the reference price feed
  /// @param newReferenceFeed New Chainlink-compatible feed address
  function setReferenceFeed(address newReferenceFeed) external;

  /// @notice Minimum discount in BPS (0.1%)
  function MIN_DISCOUNT() external view returns (uint256);

  /// @notice Maximum discount in BPS (99.9%)
  function MAX_DISCOUNT() external view returns (uint256);

  /// @notice Represents 1:1 exchange rate with 2 decimal precision
  function ONE_EXCHANGE_RATE() external view returns (uint256);

  /// @notice Represents 100% in BPS
  function ONE_HUNDRED_PERCENT_BPS() external view returns (uint256);

  /// @notice Minimum valid reference price
  function MIN_REFERENCE_PRICE() external view returns (int256);

  /// @notice Required decimals for reference feed (must be exactly 8)
  function REQUIRED_DECIMALS() external view returns (uint8);

  /// @dev Thrown when ACL Manager address is zero
  error ACLManagerIsZeroAddress();

  /// @dev Thrown when caller is not a Pool Admin
  error CallerIsNotPoolAdmin();

  /// @dev Thrown when discount is outside valid range
  error InvalidDiscount();

  /// @dev Thrown when feed address is zero
  error InvalidFeed();

  /// @dev Thrown when exchange rate is below ONE_EXCHANGE_RATE
  error InvalidExchangeRate();

  /// @dev Thrown when reference feed price is below MIN_REFERENCE_PRICE
  error PriceTooLow();

  /// @dev Thrown when reference feed decimals is not equal to REQUIRED_DECIMALS
  error InvalidDecimals();
}
