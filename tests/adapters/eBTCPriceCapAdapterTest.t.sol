// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {EBTCPriceCapAdapter} from '../../src/contracts/lst-adapters/EBTCPriceCapAdapter.sol';
import {IEBTC} from '../../src/interfaces/IEBTC.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract EBTCEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.eBTCAdapterCode(),
      30,
      ForkParams({network: 'mainnet', blockNumber: 23116000}),
      'eBTC_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new EBTCPriceCapAdapter(capAdapterParams);
  }

  function _mockRatioProviderRate(uint256 amount) internal override {
    vm.mockCall(
      CapAdaptersCodeEthereum.eBTC_ACCOUNTANT,
      abi.encodeWithSelector(IEBTC.getRate.selector),
      abi.encode(amount)
    );
  }
}
