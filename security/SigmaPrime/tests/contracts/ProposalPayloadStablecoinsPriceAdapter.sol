// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CLSynchronicityPriceAdapterBaseToPeg} from './CLSynchronicityPriceAdapterBaseToPeg.sol';
import {IAaveOracle} from './aave-address-book/AaveV2.sol';
import {AaveV2Ethereum} from './aave-address-book/AaveAddressBook.sol';

/**
 * @title ProposalPayloadStablecoinsPriceAdapter
 * @author BGD Labs
 * @notice Aave governance payload to add price adapter for stable coins
 */
contract ProposalPayloadStablecoinsPriceAdapter {
  address public constant ETH_USD_AGGREGATOR = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  function _initAssetAggregators() internal pure returns (address[] memory, address[] memory) {
    address[] memory assets = new address[](10);
    address[] memory aggregators = new address[](10);

    // USDT
    assets[0] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    aggregators[0] = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;

    // BUSD
    assets[1] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    aggregators[1] = 0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A;

    // DAI
    assets[2] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    aggregators[2] = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;

    // SUSD
    assets[3] = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    aggregators[3] = 0xad35Bd71b9aFE6e4bDc266B345c198eaDEf9Ad94;

    // tUSD
    assets[4] = 0x0000000000085d4780B73119b644AE5ecd22b376;
    aggregators[4] = 0xec746eCF986E2927Abd291a2A1716c940100f8Ba;

    // USDC
    assets[5] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    aggregators[5] = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    // GUSD
    assets[6] = 0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd;
    aggregators[6] = 0xa89f5d2365ce98B3cD68012b6f503ab1416245Fc;

    // USDP
    assets[7] = 0x8E870D67F660D95d5be530380D0eC0bd388289E1;
    aggregators[7] = 0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3;

    // FRAX
    assets[8] = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    aggregators[8] = 0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD;

    // LUSD
    assets[9] = 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0;
    aggregators[9] = 0x3D7aE7E594f2f2091Ad8798313450130d0Aba3a0;

    return (assets, aggregators);
  }

  function execute() external {
    (address[] memory assets, address[] memory aggregators) = _initAssetAggregators();
    address[] memory adapters = new address[](assets.length);

    // for each stable coin make price adapter
    for (uint8 i = 0; i < assets.length; i++) {
      CLSynchronicityPriceAdapterBaseToPeg adapter = new CLSynchronicityPriceAdapterBaseToPeg(
        ETH_USD_AGGREGATOR,
        aggregators[i],
        18
      );

      adapters[i] = address(adapter);
    }

    // set new asset source for all stable coins
    AaveV2Ethereum.ORACLE.setAssetSources(assets, adapters);
  }
}
