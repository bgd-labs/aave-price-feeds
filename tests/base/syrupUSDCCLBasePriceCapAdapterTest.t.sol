// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';

contract syrupUSDCCLBasePriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.syrupUSDCAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 39684200}),
      'syrupUSDC_CL_Base'
    )
  {}
}
