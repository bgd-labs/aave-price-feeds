// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';

import {CLRatePriceCapAdapter} from '../../src/contracts/CLRatePriceCapAdapter.sol';
import {WstETHPriceCapAdapter} from '../../src/contracts/lst-adapters/WstETHPriceCapAdapter.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';

contract wstETHEthereumTest is BaseTest {
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

contract wstETHBNBTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeBNB.wstETHAdapterCode(),
      9,
      ForkParams({network: 'bnb', blockNumber: 42738754}),
      'wstETH_BNB'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new CLRatePriceCapAdapter(capAdapterParams);
  }
}

contract wstETHLineaTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeLinea.wstETHAdapterCode(),
      14,
      ForkParams({network: 'linea', blockNumber: 15415372}),
      'wstETH_Linea'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new CLRatePriceCapAdapter(capAdapterParams);
  }
}

contract wstETHInkTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.wstETHAdapterCode(),
      14,
      ForkParams({network: 'ink', blockNumber: 32384403}),
      'wstETH_Ink'
    )
  {}
}

contract wstETHPlasmaTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodePlasma.wstETHAdapterCode(),
      14,
      ForkParams({network: 'plasma', blockNumber: 6119800}),
      'wstETH_plasma'
    )
  {}
}

contract wstETHMegaEthTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeMegaEth.wstEthAdapterCode(),
      0,
      ForkParams({network: 'megaeth', blockNumber: 7304587}),
      'wstETH_megaEth'
    )
  {}

  function test_latestAnswerRetrospective() public pure override {
    // cannot test due to newly base feed deployed
    assertTrue(true);
  }
}

contract wstETHBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.wstETHAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 42567000}),
      'wstETH_base'
    )
  {}
}

contract wstETHArbitrumTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeArbitrum.wstETHAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 435534000}),
      'wstETH_Arbitrum'
    )
  {}
}
