// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IDiscountedMKRSKYAdapter} from '../../interfaces/IDiscountedMKRSKYAdapter.sol';
import {IBasicFeed} from '../../interfaces/IBasicFeed.sol';
import {IMkrSky} from '../../interfaces/IMkrSky.sol';
import {IChainlinkAggregator} from '../../interfaces/IChainlinkAggregator.sol';

/**
 * @title DiscountedMKRSKYAdapter
 * @author BGD Labs
 * @notice Price adapter to calculate MKR price based on SKY price, a fixed exchange rate, and a dynamic discount.
 *         Designed for the Aave v3 protocol to be used during the active MKR to SKY migration.
 *
 * @dev Price Formula:
 *      MKR_price = SKY_price * EXCHANGE_RATE * (1 - discount)
 *
 *      Implementation:
 *      ((referenceFeedPrice * EXCHANGE_RATE) * (1e18 - discount())) / 1e18
 *
 *      Parameters:
 *      - REFERENCE_FEED: Chainlink SKY/USD price feed on Ethereum (constant)
 *      - EXCHANGE_RATE: MKR/SKY conversion rate (24000, meaning 1 MKR = 24000 SKY). This is a constant
 *        in the MkrSky contract, but cached here as immutable to avoid external calls on every price query.
 *      - discount(): Dynamically fetched from DISCOUNT_PROVIDER (MkrSky migration contract)
 *        Returns raw fee where 1e18 = 100%, 0.02e18 = 2%
 *
 *      Example:
 *      - SKY/USD price: $0.0665 (6650503 with 8 decimals)
 *      - Exchange rate: 24000
 *      - Discount: 2% (0.02e18)
 *      - Result: (6650503 * 24000) * (1e18 - 0.02e18) / 1e18 = ~$1564 (156489827040 with 8 decimals)
 *
 *      Constants/Immutables:
 *      - DISCOUNT_PROVIDER, REFERENCE_FEED, DESCRIPTION (constants)
 *      - EXCHANGE_RATE (cached from MkrSky.rate()), DECIMALS (immutable)
 *
 *      Assumptions:
 *      - If reference price <= 0 at query time, returns 0 (Aave handles that case)
 *      - DISCOUNT_PROVIDER returns fee (discount) in MkrSky format (1 ether = 100%)
 */
contract DiscountedMKRSKYAdapter is IDiscountedMKRSKYAdapter {
  /// @dev MkrSky migration contract on Ethereum that provides the dynamic fee/discount and exchange rate
  /// @inheritdoc IDiscountedMKRSKYAdapter
  address public constant DISCOUNT_PROVIDER = 0xA1Ea1bA18E88C381C724a75F23a130420C403f9a;

  /// @dev Chainlink SKY/USD price feed on Ethereum
  /// @inheritdoc IDiscountedMKRSKYAdapter
  IChainlinkAggregator public constant REFERENCE_FEED =
    IChainlinkAggregator(0xee10fE5E7aa92dd7b136597449c3d5813cFC5F18);

  string public constant DESCRIPTION = 'MKR/USD (calculated)';

  /// @inheritdoc IBasicFeed
  function description() external pure returns (string memory) {
    return DESCRIPTION;
  }

  /// @inheritdoc IBasicFeed
  uint8 public immutable DECIMALS;

  /// @dev MKR/SKY exchange rate cached from MkrSky.rate() (24000 = 1 MKR = 24000 SKY).
  ///      Constant in MkrSky, cached here to avoid external calls on every price query.
  /// @inheritdoc IDiscountedMKRSKYAdapter
  uint256 public immutable EXCHANGE_RATE;

  constructor() {
    DECIMALS = REFERENCE_FEED.decimals();
    EXCHANGE_RATE = IMkrSky(DISCOUNT_PROVIDER).rate();
  }

  /// @inheritdoc IBasicFeed
  function decimals() external view returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc IBasicFeed
  /// @dev Returns 0 when:
  ///      - Reference feed price <= 0
  ///      - Due to integer division truncation when: referenceFeedPrice * 24000 * (1e18 - discount) < 1e18
  ///        For example, with referenceFeedPrice = 1 (smallest unit), zeroes when discount > ~99.996%
  ///        With current SKY/USD price (~$0.0665), zeroes when discount > ~99.9999999994%
  function latestAnswer() external view virtual returns (int256) {
    int256 rawPrice = REFERENCE_FEED.latestAnswer();

    // This should never happen, but as extra validation
    if (rawPrice <= 0) return 0;

    uint256 referenceFeedPrice = uint256(rawPrice);

    // e.g. (6650503 * 24000) * (1e18 - 0.02e18) / 1e18 = 156489827040 (~$1564 with 8 decimals)
    // Safe to cast as final price will always fit into int256
    return int256(((referenceFeedPrice * EXCHANGE_RATE) * (1e18 - discount())) / 1e18);
  }

  /// @inheritdoc IDiscountedMKRSKYAdapter
  function discount() public view returns (uint256) {
    /// @dev In the MkrSky migration contract, 1e18 = 100%, 0.1e18 = 10%, 0.01e18 = 1%
    /// The value is bounded to 100%
    return IMkrSky(DISCOUNT_PROVIDER).fee();
  }
}
