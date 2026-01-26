// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// forge test --match-contract DiscountedMKRSKYAdapter -vvv
// forge coverage --match-contract DiscountedMKRSKYAdapter

import {Test} from 'forge-std/Test.sol';
import {
  DiscountedMKRSKYAdapter
} from '../../src/contracts/misc-adapters/DiscountedMKRSKYAdapter.sol';
import {IDiscountedMKRSKYAdapter} from '../../src/interfaces/IDiscountedMKRSKYAdapter.sol';
import {ChainlinkAggregatorMock} from './mocks/ChainlinkAggregatorMock.sol';
import {MkrSkyMock} from './mocks/MkrSkyMock.sol';

contract DiscountedMKRSKYAdapterTest is Test {
  IDiscountedMKRSKYAdapter adapter;
  MkrSkyMock mkrSkyMock;

  // Constant addresses matching the adapter
  address public constant MKR_SKY_ADDRESS = 0xA1Ea1bA18E88C381C724a75F23a130420C403f9a;
  address public constant SKY_USD_FEED = 0xee10fE5E7aa92dd7b136597449c3d5813cFC5F18;

  uint256 public constant EXCHANGE_RATE = 24_000; // 24000:1 (cached from MkrSky.rate())
  uint256 public constant FEE_6_PERCENT = 0.06 ether; // 6% in MkrSky format (1e18 = 100%)
  int256 public constant SKY_PRICE = 6650503; // ~$0.0665 with 8 decimals
  string public constant DESCRIPTION = 'MKR/USD (calculated)';

  function setUp() public {
    // Deploy mock and etch it at the constant DISCOUNT_PROVIDER address
    mkrSkyMock = new MkrSkyMock(FEE_6_PERCENT, EXCHANGE_RATE);
    vm.etch(MKR_SKY_ADDRESS, address(mkrSkyMock).code);
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(FEE_6_PERCENT);
    MkrSkyMock(MKR_SKY_ADDRESS).setRate(EXCHANGE_RATE);

    // Deploy mock and etch it at the constant REFERENCE_FEED address
    ChainlinkAggregatorMock referenceFeedMock = new ChainlinkAggregatorMock(SKY_PRICE);
    vm.etch(SKY_USD_FEED, address(referenceFeedMock).code);
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(SKY_PRICE);
    ChainlinkAggregatorMock(SKY_USD_FEED).setDecimals(8);

    adapter = new DiscountedMKRSKYAdapter();
  }

  function test_latestAnswer() external view {
    // Expected: (6650503 * 24000) * (1e18 - 0.06e18) / 1e18 = 150035347680
    // forge-lint: disable-next-line(unsafe-typecast)
    int256 expectedPrice = int256(
      // forge-lint: disable-next-line(unsafe-typecast)
      ((uint256(SKY_PRICE) * EXCHANGE_RATE) * (1e18 - FEE_6_PERCENT)) / 1e18
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
  }

  function test_latestAnswer_zeroOrNegativePrice() external {
    // Test zero price
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(0);
    assertEq(adapter.latestAnswer(), 0);

    // Test negative price
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(-1);
    assertEq(adapter.latestAnswer(), 0);
  }

  function test_decimals() external view {
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.DECIMALS(), 8);
  }

  function test_description() external view {
    assertEq(adapter.description(), DESCRIPTION);
  }

  function test_discount() external view {
    assertEq(adapter.discount(), FEE_6_PERCENT);
  }

  function test_exchangeRate() external view {
    assertEq(adapter.EXCHANGE_RATE(), EXCHANGE_RATE);
  }

  function test_referenceFeed() external view {
    assertEq(address(adapter.REFERENCE_FEED()), SKY_USD_FEED);
  }

  function test_discountProvider() external view {
    assertEq(adapter.DISCOUNT_PROVIDER(), MKR_SKY_ADDRESS);
  }

  function test_latestAnswer_withDifferentPrices() external {
    // Test with different reference prices
    int256 newPrice = 10_000_000; // $0.10 with 8 decimals
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(newPrice);

    // forge-lint: disable-next-line(unsafe-typecast)
    int256 expectedPrice = int256(
      // forge-lint: disable-next-line(unsafe-typecast)
      ((uint256(newPrice) * EXCHANGE_RATE) * (1e18 - FEE_6_PERCENT)) / 1e18
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
  }

  function test_latestAnswer_withDifferentDiscounts() external {
    // Test with 10% discount
    uint256 fee10Percent = 0.1 ether; // 10% in MkrSky format (1 ether = 100%)
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(fee10Percent);

    // forge-lint: disable-next-line(unsafe-typecast)
    int256 expectedPrice = int256(
      // forge-lint: disable-next-line(unsafe-typecast)
      ((uint256(SKY_PRICE) * EXCHANGE_RATE) * (1e18 - fee10Percent)) / 1e18
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
    assertEq(adapter.discount(), fee10Percent);

    // Test with 1% discount
    uint256 fee1Percent = 0.01 ether; // 1% in MkrSky format (1 ether = 100%)
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(fee1Percent);

    // forge-lint: disable-next-line(unsafe-typecast)
    expectedPrice = int256(((uint256(SKY_PRICE) * EXCHANGE_RATE) * (1e18 - fee1Percent)) / 1e18);
    assertEq(adapter.latestAnswer(), expectedPrice);
    assertEq(adapter.discount(), fee1Percent);
  }

  /// @dev Tests edge cases where latestAnswer() returns 0 due to high discount.
  ///      Per contract docs: "Due to integer division truncation when:
  ///      referenceFeedPrice * 24000 * (1e18 - discount) < 1e18"
  function test_latestAnswer_zeroFromHighDiscount() external {
    // Case 1: 100% discount always returns 0, regardless of SKY price
    uint256 fee100Percent = 1 ether;
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(fee100Percent);
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(SKY_PRICE);
    assertEq(adapter.latestAnswer(), 0);
    assertEq(adapter.discount(), fee100Percent);

    // Case 2: Higher SKY price with 100% discount still returns 0
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(50_000_000); // $0.50
    assertEq(adapter.latestAnswer(), 0);

    // Case 3: Minimum SKY price (1) with near-100% discount truncates to 0
    // For truncation: 1 * 24000 * (1e18 - discount) < 1e18
    // Solving: discount > 1e18 - (1e18 / 24000) ≈ 99.9958%
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(1);
    uint256 feeNear100Percent = 0.99996 ether; // 99.996%
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(feeNear100Percent);
    assertEq(adapter.latestAnswer(), 0);

    // Case 4: Verify high but not extreme discount still returns value with min price
    // 1 * 24000 * (1e18 - 0.99e18) / 1e18 = 24000 * 0.01 = 240
    uint256 fee99Percent = 0.99 ether;
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(fee99Percent);
    assertEq(adapter.latestAnswer(), 240);

    // Case 5: Normal SKY price with high discount returns reduced but non-zero value
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(SKY_PRICE); // ~$0.0665
    uint256 fee90Percent = 0.9 ether;
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(fee90Percent);
    // (6650503 * 24000) * (1e18 - 0.9e18) / 1e18 = 159612072 * 0.1 = 15961207
    // forge-lint: disable-next-line(unsafe-typecast)
    int256 expectedPrice = int256(
      // forge-lint: disable-next-line(unsafe-typecast)
      ((uint256(SKY_PRICE) * EXCHANGE_RATE) * (1e18 - fee90Percent)) / 1e18
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
    assertGt(adapter.latestAnswer(), 0);
  }

  function test_discount_fuzz(uint256 feeInEther) external {
    // Bound fee to full range: 0.01% to 100% (0.0001 ether to 1 ether)
    feeInEther = bound(feeInEther, 0.0001 ether, 1 ether);
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(feeInEther);

    // discount() returns raw fee directly (1e18 = 100%)
    assertEq(adapter.discount(), feeInEther);
  }

  function test_latestAnswer_fuzz(uint256 skyPrice, uint256 feeInEther) external {
    // Bound SKY price to realistic range: $0.01 to $0.50 with 8 decimals
    skyPrice = bound(skyPrice, 1_000_000, 50_000_000);

    // Bound fee to full range: 0.1% to 100% (0.001 ether to 1 ether)
    feeInEther = bound(feeInEther, 0.001 ether, 1 ether);

    // Update mock values
    // forge-lint: disable-next-line(unsafe-typecast)
    ChainlinkAggregatorMock(SKY_USD_FEED).setLatestAnswer(int256(skyPrice));
    MkrSkyMock(MKR_SKY_ADDRESS).setFee(feeInEther);

    // Calculate expected price using the same formula as the contract
    uint256 expectedPrice = ((skyPrice * EXCHANGE_RATE) * (1e18 - feeInEther)) / 1e18;

    // forge-lint: disable-next-line(unsafe-typecast)
    assertEq(adapter.latestAnswer(), int256(expectedPrice));
    assertGe(adapter.latestAnswer(), 0);
  }
}
