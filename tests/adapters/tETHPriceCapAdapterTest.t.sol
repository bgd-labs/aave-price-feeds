// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {TETHPriceCapAdapter} from '../../src/contracts/lst-adapters/TETHPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract TETHEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.tETHAdapterCode(),
      45,
      ForkParams({network: 'mainnet', blockNumber: 22724000}),
      'tETH_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new TETHPriceCapAdapter(capAdapterParams);
  }
}
