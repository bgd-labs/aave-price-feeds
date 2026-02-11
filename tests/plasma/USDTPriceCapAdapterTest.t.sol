// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';

contract USDTPriceCapAdapterPlasmaTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodePlasma.USDTAdapterCode(),
      14,
      ForkParams({network: 'plasma', blockNumber: 3693555})
    )
  {}
}
