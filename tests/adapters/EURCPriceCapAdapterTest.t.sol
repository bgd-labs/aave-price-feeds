// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract EURCEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.EURCAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 22630524})
    )
  {}
}

contract EURCBaseTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeBase.EURCAdapterCode(),
      10,
      ForkParams({network: 'base', blockNumber: 42567000})
    )
  {}
}
