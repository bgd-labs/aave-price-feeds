// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {BaseAggregatorsArbitrum} from '../../src/lib/BaseAggregators.sol';

contract PriceAdaptersArbitrumTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 59403240);
  }

  function testwstETHLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      BaseAggregatorsArbitrum.ETH_USD_AGGREGATOR,
      BaseAggregatorsArbitrum.WSTETH_STETH_AGGREGATOR,
      8,
      'wstETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      181830040000, // value calculated manually for selected block
      10000
    );
  }
}
