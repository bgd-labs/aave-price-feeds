// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract wstETHPriceCapAdapterMegaEthTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMegaEth.wstEthAdapterCode(),
      8,
      ForkParams({network: 'megaeth', blockNumber: 6702723}),
      'wstETH_megaEth'
    )
  {}
}
