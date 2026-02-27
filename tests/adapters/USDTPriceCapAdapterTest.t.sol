// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';

import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';
import {CapAdaptersCodeMegaEth} from '../../scripts/DeployMegaEth.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeSoneium} from '../../scripts/DeploySoneium.s.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';

contract USDTEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDTAdapterCode(),
      14,
      ForkParams({network: 'mainnet', blockNumber: 22195655})
    )
  {}
}

contract USDTLineaTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeLinea.USDTAdapterCode(),
      10,
      ForkParams({network: 'linea', blockNumber: 13432357})
    )
  {}
}

contract USDTMantleTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMantle.USDTAdapterCode(),
      30,
      ForkParams({network: 'mantle', blockNumber: 90210075})
    )
  {}
}

contract USDTMegaEthTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMegaEth.USDT0AdapterCode(),
      0,
      ForkParams({network: 'megaeth', blockNumber: 7304587})
    )
  {}
}

contract USDTPlasmaTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodePlasma.USDTAdapterCode(),
      14,
      ForkParams({network: 'plasma', blockNumber: 3693555})
    )
  {}
}

contract USDTSoneiumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeSoneium.USDTAdapterCode(),
      14,
      ForkParams({network: 'soneium', blockNumber: 7177569})
    )
  {}
}

contract USDTArbitrumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeArbitrum.USDTAdapterCode(),
      30,
      ForkParams({network: 'arbitrum', blockNumber: 435534000})
    )
  {}
}
