// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';


import {IChainlinkAggregator} from '../../src/interfaces/IChainlinkAggregator.sol';
import {CapAdaptersCodeZkSync} from '../../scripts/DeployZkSync.s.sol';

contract ExchangeRatesZKSync is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('zksync'), 57550360); // Mar-12-2025
  }

  function test_getExchangeRate() public view {
    uint256 weETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.weETH_eETH_AGGREGATOR).latestAnswer()
    );

    uint256 sUSDeRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.sUSDe_USDe_AGGREGATOR).latestAnswer()
    );

    uint256 rsETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.rsETH_ETH_AGGREGATOR).latestAnswer()
    );

    console.log('ZkSync');
    console.log('weETHRate', weETHRate);
    console.log('sUSDeRate', sUSDeRate);
    console.log('rsETHRate', rsETHRate);
    console.log(block.timestamp);
  }
}