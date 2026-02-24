// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {WeETHPriceCapAdapter} from '../../src/contracts/lst-adapters/WeETHPriceCapAdapter.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeScroll} from '../../scripts/DeployScroll.s.sol';

contract weETHEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.weETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24231100}),
      'weETH_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new WeETHPriceCapAdapter(capAdapterParams);
  }
}

contract weETHBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.weETHAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 14720247}),
      'weETH_base'
    )
  {}
}

contract weETHArbitrumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeArbitrum.weETHAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 197799635}),
      'weETH_arbitrum'
    )
  {}
}

contract weETHLineaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeLinea.weETHAdapterCode(),
      30,
      ForkParams({network: 'linea', blockNumber: 13423434}),
      'weETH_Linea'
    )
  {}
}

contract weETHInkTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.weETHAdapterCode(),
      14,
      ForkParams({network: 'ink', blockNumber: 31779603}),
      'weETH_Ink'
    )
  {}
}

contract weETHScrollTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeScroll.weETHAdapterCode(),
      30,
      ForkParams({network: 'scroll', blockNumber: 7951074}),
      'weETH_scroll'
    )
  {}
}

contract weETHPlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.weETHAdapterCode(),
      14,
      ForkParams({network: 'plasma', blockNumber: 3693500}),
      'weETH_plasma'
    )
  {}
}
