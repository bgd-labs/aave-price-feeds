// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {StETHtoETHSynchronicityPriceAdapter} from '../../src/contracts/misc-adapters/StETHtoETHSynchronicityPriceAdapter.sol';

contract StETHtoETHSynchronicityPriceAdapterTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 17446450);
  }

  function testLatestAnswer() public {
    StETHtoETHSynchronicityPriceAdapter adapter = new StETHtoETHSynchronicityPriceAdapter(
      'stETH/ETH'
    );

    int256 price = adapter.latestAnswer();

    assertEq(uint256(price), 1000000000000000000);
  }
}
