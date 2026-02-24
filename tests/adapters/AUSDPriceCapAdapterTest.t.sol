// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';

contract AUSDAvalancheTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeAvalanche.AUSDAdapterCode(),
      10,
      ForkParams({network: 'avalanche', blockNumber: 53614500})
    )
  {}
}
