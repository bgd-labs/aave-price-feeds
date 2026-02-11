// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../CLAdapterBaseTest.sol';

import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';

contract sUSDePriceCapAdapterAvalancheTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeAvalanche.sUSDeAdapterCode(),
      30,
      ForkParams({network: 'avalanche', blockNumber: 77096662}),
      'sUSDe_Avalanche'
    )
  {}
}
