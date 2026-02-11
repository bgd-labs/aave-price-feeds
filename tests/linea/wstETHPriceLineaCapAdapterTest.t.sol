// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {CapAdaptersCodeLinea, CLRatePriceCapAdapter} from '../../scripts/DeployLinea.s.sol';

contract wstETHPriceLineaCapAdapterTest is BaseTest {
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
