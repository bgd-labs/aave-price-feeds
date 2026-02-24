// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {LineaScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Linea} from 'aave-address-book/AaveV3Linea.sol';
import {ChainlinkLinea} from 'aave-address-book/ChainlinkLinea.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {FixedPriceAdapter} from '../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IPriceCapAdapter, IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeLinea {
  address public constant ezETH_ETH_AGGREGATOR = 0xb71F79770BA599940F454c70e63d4DE0E8606731;
  address public constant weETH_eETH_AGGREGATOR = 0x1FBc7d24654b10c71fd74d3730d9Df17836181EF;
  address public constant wstETH_stETH_AGGREGATOR = 0x3C8A95F2264bB3b52156c766b738357008d87cB7;
  address public constant WETH_PRICE_FEED = 0x3c6Cd9Cc7c7a4c2Cf5a82734CD249D7D593354dA;
  address public constant USDC_PRICE_FEED = 0xAADAa473C1bDF7317ec07c915680Af29DeBfdCb5;
  address public constant USDT_PRICE_FEED = 0xefCA2bbe0EdD0E22b2e0d2F8248E99F4bEf4A7dB;
  address public constant wrsETH_rsETH_AGGREGATOR = 0xEEDF0B095B5dfe75F3881Cb26c19DA209A27463a;

  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            baseAggregatorAddress: WETH_PRICE_FEED,
            ratioProviderAddress: weETH_eETH_AGGREGATOR,
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1054169605180649721,
              snapshotTimestamp: 1733109809,
              maxYearlyRatioGrowthPercent: 8_75
            })
          })
        )
      );
  }

  function ezETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            baseAggregatorAddress: WETH_PRICE_FEED,
            ratioProviderAddress: ezETH_ETH_AGGREGATOR,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1029140608890425422,
              snapshotTimestamp: 1733109809,
              maxYearlyRatioGrowthPercent: 10_89
            })
          })
        )
      );
  }

  function wstETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            baseAggregatorAddress: WETH_PRICE_FEED,
            ratioProviderAddress: wstETH_stETH_AGGREGATOR,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1190272828525538502,
              snapshotTimestamp: 1736592058, // Jan-11-2025
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function USDCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDC_PRICE_FEED),
            adapterDescription: 'Capped USDC/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDT_PRICE_FEED),
            adapterDescription: 'Capped USDT/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function wrsETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            baseAggregatorAddress: WETH_PRICE_FEED,
            ratioProviderAddress: wrsETH_rsETH_AGGREGATOR,
            pairDescription: 'Capped wrsETH / rsETH(ETH) / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_038839717415900257,
              snapshotTimestamp: 1741541239, // Mar-09-2025
              maxYearlyRatioGrowthPercent: 9_83
            })
          })
        )
      );
  }

  function mUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Linea.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkLinea.MUSD__USD),
            adapterDescription: 'Capped mUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function fixedMUsdAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(address(AaveV3Linea.ACL_MANAGER), 8, int256(1 * 1e8), 'Fixed mUSD/USD')
      );
  }
}

contract DeployWeEthLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.weETHAdapterCode());
  }
}

contract DeployEzEthLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.ezETHAdapterCode());
  }
}

contract DeployUSDCLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.USDCAdapterCode());
  }
}

contract DeployUSDTLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.USDTAdapterCode());
  }
}

contract DeployWstETHLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.wstETHAdapterCode());
  }
}

contract DeployWRstETHLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.wrsETHAdapterCode());
  }
}

contract DeployMUSDLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.mUSDAdapterCode());
  }
}

contract DeployFixedMUSDLinea is LineaScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeLinea.fixedMUsdAdapterCode());
  }
}
