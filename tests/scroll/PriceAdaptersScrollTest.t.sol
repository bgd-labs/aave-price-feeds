// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {BaseAggregatorsScroll} from '../../src/lib/BaseAggregators.sol';

contract PriceAdaptersScrollTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('scroll'), 2668614);
  }

  function testwstETHLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      BaseAggregatorsScroll.ETH_USD_AGGREGATOR,
      BaseAggregatorsScroll.WSTETH_STETH_AGGREGATOR,
      8,
      'wstETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      2807_24011742, // value calculated manually for selected block
      10000
    );
  }
}
