// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';

library stEURCapAdapters {
  function agEURAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          AaveV3Ethereum.ACL_MANAGER,
          MiscEthereum.agEUR_EUR_AGGREGATOR,
          'Capped agEUR/EUR',
          int256(1.04 * 1e18)
        )
      );
  }

  function agEURtoUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLSynchronicityPriceAdapterPegToBase).creationCode,
        abi.encode(
          MiscEthereum.EUR_USD_AGGREGATOR, // EUR to USD
          GovV3Helpers.predictDeterministicAddress(agEURAdapterCode()), // agEUR / EUR / USD
          18, // agEUR / EUR
          'Capped agEUR / EUR / USD'
        )
      );
  }
}
