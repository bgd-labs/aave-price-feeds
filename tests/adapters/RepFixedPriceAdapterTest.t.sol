// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {RepFixedPriceAdapter} from '../../src/contracts/misc-adapters/RepFixedPriceAdapter.sol';

contract RepFixedPriceAdapterTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 18469687);
  }

  function testLatestAnswer() public {
    RepFixedPriceAdapter adapter = new RepFixedPriceAdapter();

    int256 price = adapter.latestAnswer();

    assertEq(price, 462569569300000);
  }
}
