// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract USDTPriceCapAdapterMegaEthTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMegaEth.USDT0AdapterCode(),
      0,
      ForkParams({network: 'megaeth', blockNumber: 7304587})
    )
  {}
}
