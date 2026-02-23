// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {SyrupUSDTPriceCapAdapter} from '../../src/contracts/lst-adapters/SyrupUSDTPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';

contract syrupUSDTEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.syrupUSDTAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 23697800}),
      'SyrupUSDT_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new SyrupUSDTPriceCapAdapter(capAdapterParams);
  }
}

contract syrupUSDTMantleTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.syrupUSDTAdapterCode(),
      7,
      ForkParams({network: 'mantle', blockNumber: 90952191}),
      'syrupUSDT_Mantle'
    )
  {}
}

contract syrupUSDTPlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.syrupUSDTAdapterCode(),
      7,
      ForkParams({network: 'plasma', blockNumber: 3681000}),
      'syrupUSDT_plasma'
    )
  {}
}
