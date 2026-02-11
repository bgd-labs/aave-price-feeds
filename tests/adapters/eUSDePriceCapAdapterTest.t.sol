// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import '../BaseTest.sol';

import {EUSDePriceCapAdapter} from '../../src/contracts/lst-adapters/EUSDePriceCapAdapter.sol';
import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';
import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

contract EUSDeEthereumTest is BaseTest {
  constructor()
    BaseTest(
      CapAdaptersCodeEthereum.eUSDeAdapterCode(),
      45,
      ForkParams({network: 'mainnet', blockNumber: 22325000}),
      'eUSDe_Ethereum'
    )
  {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new EUSDePriceCapAdapter(capAdapterParams);
  }

  function _mockRatioProviderRate(uint256 amount) internal override {
    vm.mockCall(
      CapAdaptersCodeEthereum.eUSDe,
      abi.encodeWithSelector(IERC4626.convertToAssets.selector, 1 ether),
      abi.encode(amount)
    );
  }
}
