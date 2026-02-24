// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';
import {FixedPriceAdapter, IFixedPriceAdapter, IACLManager} from '../../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {ACLManagerMock} from './mocks/ACLManagerMock.sol';

contract FixedPriceAdapterTest is Test {
  FixedPriceAdapter fixedPriceAdapter;
  IACLManager aclManager;

  address public constant POOL_ADMIN = address(50);

  int256 public constant FIXED_PRICE = 1e18;
  uint8 public constant DECIMALS = 8;
  string public DESCRIPTION = 'Fixed USDG / USD';

  function setUp() public {
    aclManager = IACLManager(address(new ACLManagerMock(POOL_ADMIN, address(0))));
    fixedPriceAdapter = new FixedPriceAdapter(
      address(aclManager),
      DECIMALS,
      FIXED_PRICE,
      DESCRIPTION
    );
  }

  function test_latestAnswer() external view {
    assertEq(fixedPriceAdapter.latestAnswer(), FIXED_PRICE);
    assertEq(fixedPriceAdapter.price(), FIXED_PRICE);
  }

  function test_decimals() external view {
    assertEq(fixedPriceAdapter.decimals(), DECIMALS);
    assertEq(fixedPriceAdapter.DECIMALS(), DECIMALS);
  }

  function test_description() external view {
    assertEq(fixedPriceAdapter.description(), DESCRIPTION);
  }

  function test_setPrice(int256 newFixedPrice) external {
    int256 initialPrice = fixedPriceAdapter.price();
    vm.prank(POOL_ADMIN);

    if (newFixedPrice >= 0) {
      vm.expectEmit(true, true, true, true);
      emit IFixedPriceAdapter.FixedPriceUpdated(initialPrice, newFixedPrice);

      fixedPriceAdapter.setPrice(newFixedPrice);
      assertEq(fixedPriceAdapter.price(), newFixedPrice);
    } else {
      vm.expectRevert(IFixedPriceAdapter.InvalidPrice.selector);
      fixedPriceAdapter.setPrice(newFixedPrice);
    }
  }

  function test_setPrice_callerNotPoolAdmin(address caller) external {
    vm.assume(caller != POOL_ADMIN);
    vm.prank(caller);

    vm.expectRevert(IFixedPriceAdapter.CallerIsNotPoolAdmin.selector);
    fixedPriceAdapter.setPrice(1);
  }
}
