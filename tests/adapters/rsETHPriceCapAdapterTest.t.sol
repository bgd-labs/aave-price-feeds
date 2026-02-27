// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {RsETHPriceCapAdapter} from '../../src/contracts/lst-adapters/RsETHPriceCapAdapter.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeAvalanche} from '../../scripts/DeployAvalanche.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';

contract rsETHEthereumTest is BaseTest {
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

contract rsETHArbitrumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeArbitrum.rsETHAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 435769000}),
      'RsETH_Arbitrum'
    )
  {}
}

contract rsETHBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.rsETHCLAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 42567000}),
      'RsETH_CL_Base'
    )
  {}
}

contract wrsETHLineaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeLinea.wrsETHAdapterCode(),
      90,
      ForkParams({network: 'linea', blockNumber: 17346100}),
      'WRsETH_Linea'
    )
  {}
}

contract wrsETHMantleTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMantle.wrsETHAdapterCode(),
      3,
      ForkParams({network: 'mantle', blockNumber: 90952191}),
      'WRsETH_Mantle'
    )
  {}
}

contract wrsETHInkTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.wrsETHAdapterCode(),
      14,
      ForkParams({network: 'ink', blockNumber: 31174803}),
      'wrsETH_Ink'
    )
  {}
}

contract wrsETHAvalancheTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeAvalanche.wrsETHAdapterCode(),
      14,
      ForkParams({network: 'avalanche', blockNumber: 71355400}),
      'WRsETH_Avalanche'
    )
  {}
}

contract wrsETHMegaEthTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMegaEth.wrsEthAdapterCode(),
      0,
      ForkParams({network: 'megaeth', blockNumber: 7304587}),
      'wrsETH_MegaEth'
    )
  {}

  function test_latestAnswerRetrospective() public pure override {
    // cannot test due to newly base feed deployed
    assertTrue(true);
  }
}

contract wrsETHPlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.wrsETHAdapterCode(),
      30,
      ForkParams({network: 'plasma', blockNumber: 7418169}),
      'WrsETH_Plasma'
    )
  {}
}
