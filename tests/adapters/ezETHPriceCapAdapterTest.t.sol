// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {EzETHPriceCapAdapter} from '../../src/contracts/lst-adapters/EzETHPriceCapAdapter.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract ezETHEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.ezETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24282200}),
      'EzETH_EthereumLido'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new EzETHPriceCapAdapter(capAdapterParams);
  }
}

contract ezETHBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.ezETHAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 42567000}),
      'ezETH_base'
    )
  {}
}
import 'forge-std/console.sol';

contract ezETHArbitrumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeArbitrum.ezETHAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 435769000}),
      'ezETH_arbitrum'
    )
  {}
}

contract ezETHInkTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.ezETHAdapterCode(),
      14,
      ForkParams({network: 'ink', blockNumber: 31174803}),
      'ezETH_Ink'
    )
  {}
}

contract ezETHLineaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeLinea.ezETHAdapterCode(),
      30,
      ForkParams({network: 'linea', blockNumber: 13423434}),
      'ezETH_Linea'
    )
  {}
}

contract ezETHMegaEthTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMegaEth.ezEthAdapterCode(),
      0,
      ForkParams({network: 'megaeth', blockNumber: 7304587}),
      'ezETH_MegaEth'
    )
  {}

  function test_latestAnswerRetrospective() public pure override {
    // cannot test due to newly base feed deployed
    assertTrue(true);
  }
}
