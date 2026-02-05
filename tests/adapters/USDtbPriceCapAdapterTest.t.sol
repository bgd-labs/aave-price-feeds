// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract USDtbEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDtbAdapterCode(),
      40,
      ForkParams({network: 'mainnet', blockNumber: 22296000})
    )
  {}
}
