// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';

contract syrupUSDTMantlePriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.syrupUSDTAdapterCode(),
      7,
      ForkParams({network: 'mantle', blockNumber: 90952191}),
      'syrupUSDT_Mantle'
    )
  {}
}
