// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {LBTCPriceCapAdapter, IPriceCapAdapter} from '../../src/contracts/lst-adapters/LBTCPriceCapAdapter.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {ILBTC} from '../../src/interfaces/ILBTC.sol';

contract LBTCEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.lBTCAdapterCode(),
      7,
      ForkParams({network: 'mainnet', blockNumber: 23033850}),
      'LBTC_Ethereum'
    )
  {}

  function _mockRatioProviderRate(uint256 amount) internal override {
    vm.mockCall(
      CapAdaptersCodeEthereum.LBTC_STAKE_ORACLE,
      abi.encodeWithSelector(ILBTC.getRate.selector),
      abi.encode(amount)
    );
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new LBTCPriceCapAdapter(capAdapterParams);
  }
}

contract LBTCBaseTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeBase.lBTCAdapterCode(),
      30,
      ForkParams({network: 'base', blockNumber: 42567000}),
      'LBTC_Base'
    )
  {}

  function _mockRatioProviderRate(uint256 amount) internal override {
    vm.mockCall(
      CapAdaptersCodeBase.LBTC_STAKE_ORACLE,
      abi.encodeWithSelector(ILBTC.getRate.selector),
      abi.encode(amount)
    );
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new LBTCPriceCapAdapter(capAdapterParams);
  }
}
