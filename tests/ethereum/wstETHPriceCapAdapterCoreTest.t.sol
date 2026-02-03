// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {WstETHPriceCapAdapter} from '../../src/contracts/lst-adapters/WstETHPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract wstETHPriceCapAdapterCoreTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.wstETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24231100}),
      'wstETH_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new WstETHPriceCapAdapter(capAdapterParams);
  }
}
