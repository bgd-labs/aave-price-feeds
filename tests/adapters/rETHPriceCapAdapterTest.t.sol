// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {RETHPriceCapAdapter} from '../../src/contracts/lst-adapters/RETHPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract rETHEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.rETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24231100}),
      'rETH_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new RETHPriceCapAdapter(capAdapterParams);
  }
}
