// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract ezETHMegaEthPriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMegaEth.ezEthAdapterCode(),
      20,
      ForkParams({network: 'megaeth', blockNumber: 6702723}),
      'ezETH_MegaEth'
    )
  {}
}
