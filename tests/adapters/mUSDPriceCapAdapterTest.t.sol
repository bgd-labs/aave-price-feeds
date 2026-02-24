// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';

contract mUSDEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.mUSDAdapterCode(),
      14,
      ForkParams({network: 'mainnet', blockNumber: 23717900})
    )
  {}
}

contract mUSDLineaTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeLinea.mUSDAdapterCode(),
      10,
      ForkParams({network: 'linea', blockNumber: 25224700})
    )
  {}
}
