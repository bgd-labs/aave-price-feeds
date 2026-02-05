// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {SyrupUSDCPriceCapAdapter} from '../../src/contracts/lst-adapters/SyrupUSDCPriceCapAdapter.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract syrupUSDCEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.syrupUSDCAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 23531848}),
      'SyrupUSDC_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new SyrupUSDCPriceCapAdapter(capAdapterParams);
  }
}

contract syrupUSDCBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.syrupUSDCAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 39684200}),
      'syrupUSDC_CL_Base'
    )
  {}
}
