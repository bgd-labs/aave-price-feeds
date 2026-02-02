// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {RsETHPriceCapAdapter} from '../../src/contracts/lst-adapters/RsETHPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract RsETHPriceCapAdapterTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.rsETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24282200}),
      'RsETH_EthereumLido'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new RsETHPriceCapAdapter(capAdapterParams);
  }
}
