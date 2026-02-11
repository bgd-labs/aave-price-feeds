// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';

contract USDCInkPriceCapAdapterTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeInk.USDCAdapterCode(),
      10,
      ForkParams({network: 'ink', blockNumber: 30822600})
    )
  {}
}
