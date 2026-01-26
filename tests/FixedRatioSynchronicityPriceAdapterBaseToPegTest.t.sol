// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {FixedRatioSynchronicityPriceAdapterBaseToPeg} from '../src/contracts/FixedRatioSynchronicityPriceAdapterBaseToPeg.sol';
import {ICLSynchronicityPriceAdapter} from '../src/interfaces/ICLSynchronicityPriceAdapter.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';
import {BaseAggregatorsMainnet} from '../src/lib/BaseAggregators.sol';

contract FixedRatioSynchronicityPriceAdapterBaseToPegTest is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 17715870);
  }

  function testDecimalsAboveLimit() public {
    vm.expectRevert(ICLSynchronicityPriceAdapter.DecimalsAboveLimit.selector);

    new FixedRatioSynchronicityPriceAdapterBaseToPeg(
      BaseAggregatorsMainnet.ETH_USD_AGGREGATOR,
      95_00,
      20,
      '0.95/USD/ETH'
    );
  }

  function testRatioOutOfBounds() public {
    vm.expectRevert(ICLSynchronicityPriceAdapter.RatioOutOfBounds.selector);

    new FixedRatioSynchronicityPriceAdapterBaseToPeg(
      BaseAggregatorsMainnet.ETH_USD_AGGREGATOR,
      100_00,
      18,
      '0.95/USD/ETH'
    );

    vm.expectRevert(ICLSynchronicityPriceAdapter.RatioOutOfBounds.selector);

    new FixedRatioSynchronicityPriceAdapterBaseToPeg(
      BaseAggregatorsMainnet.ETH_USD_AGGREGATOR,
      0,
      18,
      '0.95/USD/ETH'
    );
  }

  function testLatestAnswer() public {
    FixedRatioSynchronicityPriceAdapterBaseToPeg adapter = new FixedRatioSynchronicityPriceAdapterBaseToPeg(
        BaseAggregatorsMainnet.ETH_USD_AGGREGATOR,
        95_00,
        18,
        '0.95/USD/ETH'
      );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      495094400000000, // value calculated manually for selected block
      100000000
    );
  }
}
