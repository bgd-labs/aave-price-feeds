// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';

contract sUSDeMantlePriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.sUSDeAdapterCode(),
      7,
      ForkParams({network: 'mantle', blockNumber: 90127892}),
      'sUSDe_Mantle'
    )
  {}
}
