// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract USDSEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDSAdapterCode(),
      10,
      ForkParams({network: 'mainnet', blockNumber: 20729672})
    )
  {}
}
