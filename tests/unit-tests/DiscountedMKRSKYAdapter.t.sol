// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// forge test --match-contract DiscountedMKRSKYAdapter -vvv
// forge coverage --match-contract DiscountedMKRSKYAdapter

import {Test} from 'forge-std/Test.sol';
import {
  DiscountedMKRSKYAdapter
} from '../../src/contracts/misc-adapters/DiscountedMKRSKYAdapter.sol';
import {IDiscountedMKRSKYAdapter} from '../../src/interfaces/IDiscountedMKRSKYAdapter.sol';
import {IACLManager} from 'aave-address-book/AaveV3.sol';
import {ACLManagerMock} from './mocks/ACLManagerMock.sol';
import {ChainlinkAggregatorMock} from './mocks/ChainlinkAggregatorMock.sol';

contract DiscountedMKRSKYAdapterTest is Test {
  IDiscountedMKRSKYAdapter adapter;
  IACLManager aclManager;
  ChainlinkAggregatorMock referenceFeed;

  address public constant POOL_ADMIN = address(50);

  uint256 public constant DISCOUNT = 6_00; // 6%
  uint256 public constant EXCHANGE_RATE = 24_000_00; // 24000:1
  uint256 public constant ONE_HUNDRED_PERCENT_BPS = 100_00;
  int256 public constant SKY_PRICE = 6650503; // ~$0.0665 with 8 decimals
  string public DESCRIPTION = 'MKR/USD (calculated)';

  function setUp() public {
    aclManager = IACLManager(address(new ACLManagerMock(POOL_ADMIN, address(0))));
    referenceFeed = new ChainlinkAggregatorMock(SKY_PRICE);
    adapter = new DiscountedMKRSKYAdapter(
      address(aclManager),
      DISCOUNT,
      address(referenceFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_latestAnswer() external view {
    // Expected: (6650503 * 24000_00 / 1_00) * (100_00 - 6_00) / 100_00 = 1500_35347680
    // Simplified: (6650503 * 24000_00) * (100_00 - 6_00) / 1000000 = 150035347680
    int256 expectedPrice = int256(
      ((uint256(SKY_PRICE) * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - DISCOUNT)) / 1_000_000
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
  }

  function test_latestAnswer_zeroOrNegativePrice() external {
    // Test zero price
    referenceFeed.setLatestAnswer(0);
    assertEq(adapter.latestAnswer(), 0);

    // Test negative price
    referenceFeed.setLatestAnswer(-1);
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
    assertEq(adapter.discount(), DISCOUNT);
  }

  function test_exchangeRate() external view {
    assertEq(adapter.EXCHANGE_RATE(), EXCHANGE_RATE);
  }

  function test_referenceFeed() external view {
    assertEq(address(adapter.referenceFeed()), address(referenceFeed));
  }

  function test_setDiscount(uint256 newDiscount) external {
    uint256 initialDiscount = adapter.discount();
    vm.prank(POOL_ADMIN);

    if (newDiscount >= 10 && newDiscount <= 99_90) {
      vm.expectEmit(true, true, true, true);
      emit IDiscountedMKRSKYAdapter.DiscountUpdated(initialDiscount, newDiscount);

      adapter.setDiscount(newDiscount);
      assertEq(adapter.discount(), newDiscount);
    } else {
      vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidDiscount.selector);
      adapter.setDiscount(newDiscount);
    }
  }

  function test_setDiscount_callerNotPoolAdmin(address caller) external {
    vm.assume(caller != POOL_ADMIN);
    vm.prank(caller);

    vm.expectRevert(IDiscountedMKRSKYAdapter.CallerIsNotPoolAdmin.selector);
    adapter.setDiscount(10_00);
  }

  function test_setReferenceFeed() external {
    ChainlinkAggregatorMock newFeed = new ChainlinkAggregatorMock(SKY_PRICE);
    address initialFeed = address(adapter.referenceFeed());

    vm.prank(POOL_ADMIN);
    vm.expectEmit(true, true, true, true);
    emit IDiscountedMKRSKYAdapter.ReferenceFeedUpdated(initialFeed, address(newFeed));

    adapter.setReferenceFeed(address(newFeed));
    assertEq(address(adapter.referenceFeed()), address(newFeed));
  }

  function test_setReferenceFeed_zeroAddress() external {
    vm.prank(POOL_ADMIN);
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidFeed.selector);
    adapter.setReferenceFeed(address(0));
  }

  function test_setReferenceFeed_priceTooLow() external {
    ChainlinkAggregatorMock lowPriceFeed = new ChainlinkAggregatorMock(999); // Below MIN_REFERENCE_PRICE

    vm.prank(POOL_ADMIN);
    vm.expectRevert(IDiscountedMKRSKYAdapter.PriceTooLow.selector);
    adapter.setReferenceFeed(address(lowPriceFeed));
  }

  function test_setReferenceFeed_callerNotPoolAdmin(address caller) external {
    vm.assume(caller != POOL_ADMIN);
    vm.prank(caller);

    vm.expectRevert(IDiscountedMKRSKYAdapter.CallerIsNotPoolAdmin.selector);
    adapter.setReferenceFeed(address(referenceFeed)); // Use existing valid feed
  }

  function test_constructor_aclManagerZeroAddress() external {
    vm.expectRevert(IDiscountedMKRSKYAdapter.ACLManagerIsZeroAddress.selector);
    new DiscountedMKRSKYAdapter(
      address(0),
      DISCOUNT,
      address(referenceFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_constructor_invalidDiscount() external {
    // Test discount below minimum (10 = 0.1%)
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidDiscount.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      9, // below 10
      address(referenceFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );

    // Test discount above maximum (99_90 = 99.9%)
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidDiscount.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      99_91, // above 99_90
      address(referenceFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_constructor_invalidFeed() external {
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidFeed.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      DISCOUNT,
      address(0),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_constructor_invalidExchangeRate() external {
    // Test exchange rate below minimum (1_00 = 1:1)
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidExchangeRate.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      DISCOUNT,
      address(referenceFeed),
      99, // below 1_00
      DESCRIPTION
    );
  }

  function test_constructor_priceTooLow() external {
    ChainlinkAggregatorMock lowPriceFeed = new ChainlinkAggregatorMock(999); // Below MIN_REFERENCE_PRICE

    vm.expectRevert(IDiscountedMKRSKYAdapter.PriceTooLow.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      DISCOUNT,
      address(lowPriceFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_constructor_invalidDecimals() external {
    ChainlinkAggregatorMock invalidDecimalsFeed = new ChainlinkAggregatorMock(SKY_PRICE);
    invalidDecimalsFeed.setDecimals(6); // Not 8

    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidDecimals.selector);
    new DiscountedMKRSKYAdapter(
      address(aclManager),
      DISCOUNT,
      address(invalidDecimalsFeed),
      EXCHANGE_RATE,
      DESCRIPTION
    );
  }

  function test_setReferenceFeed_invalidDecimals() external {
    ChainlinkAggregatorMock invalidDecimalsFeed = new ChainlinkAggregatorMock(SKY_PRICE);
    invalidDecimalsFeed.setDecimals(18); // Not 8

    vm.prank(POOL_ADMIN);
    vm.expectRevert(IDiscountedMKRSKYAdapter.InvalidDecimals.selector);
    adapter.setReferenceFeed(address(invalidDecimalsFeed));
  }

  function test_latestAnswer_withDifferentValues() external {
    // Test with different reference prices
    int256 newPrice = 10_000_000; // $0.10 with 8 decimals
    referenceFeed.setLatestAnswer(newPrice);

    int256 expectedPrice = int256(
      ((uint256(newPrice) * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - DISCOUNT)) / 1_000_000
    );
    assertEq(adapter.latestAnswer(), expectedPrice);

    // Test with different discount
    vm.prank(POOL_ADMIN);
    adapter.setDiscount(10_00); // 10%

    expectedPrice = int256(
      ((uint256(newPrice) * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - 10_00)) / 1_000_000
    );
    assertEq(adapter.latestAnswer(), expectedPrice);
  }

  function test_latestAnswer_fuzz(uint256 skyPrice, uint256 fuzzDiscount) external {
    // Bound SKY price to realistic range: $0.01 to $0.50 with 8 decimals
    // Current SKY price ~6650503 (~$0.0665)
    skyPrice = bound(skyPrice, 1_000_000, 50_000_000);

    // Bound discount to valid range
    fuzzDiscount = bound(fuzzDiscount, adapter.MIN_DISCOUNT(), adapter.MAX_DISCOUNT());

    // Update adapter parameters
    referenceFeed.setLatestAnswer(int256(skyPrice));

    vm.prank(POOL_ADMIN);
    adapter.setDiscount(fuzzDiscount);

    // Calculate expected price: (skyPrice * EXCHANGE_RATE) * (ONE_HUNDRED_PERCENT_BPS - discount) / (ONE_HUNDRED_PERCENT_BPS * ONE_EXCHANGE_RATE)
    uint256 expectedPrice = ((skyPrice * EXCHANGE_RATE) *
      (ONE_HUNDRED_PERCENT_BPS - fuzzDiscount)) / 1_000_000;

    assertEq(adapter.latestAnswer(), int256(expectedPrice));

    // Sanity check: MKR price should be roughly skyPrice * exchangeRate * (1 - discount)
    // With SKY ~$0.0665 and rate 24000, MKR should be ~$1500 (150000000000 with 8 decimals)
    assertGt(adapter.latestAnswer(), 0);
  }

  function test_latestAnswer_fuzz_edgeCases(
    uint256 skyPrice,
    uint256 fuzzDiscount,
    uint256 fuzzExchangeRate
  ) external {
    // Test with full valid ranges (not just realistic)
    skyPrice = bound(skyPrice, uint256(adapter.MIN_REFERENCE_PRICE()), 1_000_000_000); // Up to $10
    fuzzDiscount = bound(fuzzDiscount, adapter.MIN_DISCOUNT(), adapter.MAX_DISCOUNT());
    // Exchange rate: from 1:1 to 100000:1 (reasonable upper bound to avoid overflow)
    fuzzExchangeRate = bound(fuzzExchangeRate, adapter.ONE_EXCHANGE_RATE(), 100_000_00);

    // Need a new adapter since exchange rate is immutable
    ChainlinkAggregatorMock fuzzFeed = new ChainlinkAggregatorMock(int256(skyPrice));
    DiscountedMKRSKYAdapter fuzzAdapter = new DiscountedMKRSKYAdapter(
      address(aclManager),
      fuzzDiscount,
      address(fuzzFeed),
      fuzzExchangeRate,
      DESCRIPTION
    );

    uint256 expectedPrice = ((skyPrice * fuzzExchangeRate) *
      (ONE_HUNDRED_PERCENT_BPS - fuzzDiscount)) / 1_000_000;

    assertEq(fuzzAdapter.latestAnswer(), int256(expectedPrice));
    assertGe(fuzzAdapter.latestAnswer(), 0);
  }
}
