// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseStableTest.sol';
import {PriceCapAdapterStable} from '../../src/contracts/PriceCapAdapterStable.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodeMantle} from '../../scripts/DeployMantle.s.sol';
import {CapAdaptersCodeSoneium} from '../../scripts/DeploySoneium.s.sol';

contract USDCEthereumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeEthereum.USDCAdapterCode(),
      14,
      ForkParams({network: 'mainnet', blockNumber: 22195655})
    )
  {}
}

contract USDCInkTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeInk.USDCAdapterCode(),
      10,
      ForkParams({network: 'ink', blockNumber: 30822600})
    )
  {}
}

contract USDCLineaTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeLinea.USDCAdapterCode(),
      10,
      ForkParams({network: 'linea', blockNumber: 13432357})
    )
  {}
}

contract USDCMantleTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeMantle.USDCAdapterCode(),
      30,
      ForkParams({network: 'mantle', blockNumber: 90209274})
    )
  {}
}

contract USDCSoneiumTest is BaseStableTest {
  constructor()
    BaseStableTest(
      CapAdaptersCodeSoneium.USDCAdapterCode(),
      14,
      ForkParams({network: 'soneium', blockNumber: 7177569})
    )
  {}
}
