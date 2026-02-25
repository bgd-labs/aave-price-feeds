// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';

contract FRAXArbitrumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeArbitrum.FRAXAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 435534000})
    )
  {}
}
