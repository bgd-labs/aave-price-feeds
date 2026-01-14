// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';

contract wrsETHMantlePriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.wrsETHAdapterCode(),
      1,
      ForkParams({network: 'mantle', blockNumber: 90127892}),
      'WRsETH_Mantle'
    )
  {}
}
