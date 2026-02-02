// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../CLAdapterBaseTest.sol';

import {CLRatePriceCapAdapter} from '../../src/contracts/CLRatePriceCapAdapter.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';

contract sUSDePriceCapAdapterPlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.sUSDeAdapterParams(),
      14,
      ForkParams({network: 'plasma', blockNumber: 3764593}),
      'sUSDe_Plasma'
    )
  {}
}
