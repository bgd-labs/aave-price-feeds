// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {CapAdaptersCodeBNB, BNBxPriceCapAdapter} from '../../scripts/DeployBnb.s.sol';

contract BNBxBscTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeBNB.BNBxAdapterCode(),
      30,
      ForkParams({network: 'bnb', blockNumber: 43568801}),
      'BNBx_BNB'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new BNBxPriceCapAdapter(capAdapterParams);
  }
}
