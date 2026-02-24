// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../tests/BaseStableTest.sol';

import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeZkSync} from '../../scripts/DeployZkSync.s.sol';

contract USDePriceCapAdapterZKSyncTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeZkSync.USDeAdapterParams(),
      35,
      ForkParams({network: 'zksync', blockNumber: 49309220})
    )
  {}
}
