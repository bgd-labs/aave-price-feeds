// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {CbETHPriceCapAdapter} from '../../src/contracts/lst-adapters/CbETHPriceCapAdapter.sol';
import {CapAdaptersCodeEthereum, AaveV3Ethereum, AaveV3EthereumAssets, ChainlinkEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';

contract CbETHEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.cbETHAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 24231100}),
      'cbETH_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new CbETHPriceCapAdapter(capAdapterParams);
  }
}

contract cbETHBaseTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeBase.cbETHAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 42567000}),
      'cbETH_Base'
    )
  {}
}