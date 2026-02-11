// // SPDX-License-Identifier: BUSL-1.1
// pragma solidity ^0.8.0;

// import '../BaseTest.sol';
// import {sDAIMainnetPriceCapAdapter} from '../../src/contracts/lst-adapters/sDAIMainnetPriceCapAdapter.sol';
// import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';

// contract sDAIMainnetPriceCapAdapterTest is BaseTest {
//   constructor()
//     BaseTest(
//       CapAdaptersCodeEthereum.sDAIAdapterCode(),
//       20,
//       ForkParams({network: 'mainnet', blockNumber: 22489138}),
//       'sDAI_Ethereum'
//     )
//   {}

//   function _createAdapter(
//     IPriceCapAdapter.CapAdapterParams memory capAdapterParams
//   ) internal override returns (IPriceCapAdapter) {
//     return new sDAIMainnetPriceCapAdapter(capAdapterParams);
//   }
// }
