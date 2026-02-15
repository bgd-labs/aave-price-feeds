// SPDX-License-Identifier:  BUSL-1.1
pragma solidity ^0.8.0;

import {BaseTest} from '../BaseTest.sol';
import {CapAdaptersCodeSonic} from '../../scripts/DeploySonic.s.sol';
import {StSPriceCapAdapter, IPriceCapAdapter} from '../../src/contracts/lst-adapters/StSPriceCapAdapter.sol';

contract StSSonicTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeSonic.stSAdapterCode(),
      45,
      ForkParams({network: 'sonic', blockNumber: 17668000}),
      'stS_Sonic'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new StSPriceCapAdapter(capAdapterParams);
  }
}
