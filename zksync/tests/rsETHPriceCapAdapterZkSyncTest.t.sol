// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../../tests/BaseTest.sol';

import {CLRatePriceCapAdapter} from '../../src/contracts/CLRatePriceCapAdapter.sol';
import {CapAdaptersCodeZkSync, AaveV3ZkSyncAssets, AaveV3ZkSync} from '../../scripts/DeployZkSync.s.sol';

contract rsETHPriceCapAdapterZkSyncTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeZkSync.rsETHAdapterParams(),
      14,
      ForkParams({network: 'zksync', blockNumber: 60120360}),
      'rsETH_ZkSync'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new CLRatePriceCapAdapter{salt: 'test'}(capAdapterParams);
  }
}
