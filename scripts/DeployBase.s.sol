// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {BaseScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {ChainlinkBase} from 'aave-address-book/ChainlinkBase.sol';

import {EURPriceCapAdapterStable, IEURPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/misc-adapters/EURPriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {LBTCPriceCapAdapter} from '../src/contracts/lst-adapters/LBTCPriceCapAdapter.sol';

library CapAdaptersCodeBase {
  address public constant weETH_eETH_AGGREGATOR = 0x35e9D7001819Ea3B39Da906aE6b06A62cfe2c181;
  address public constant ezETH_ETH_AGGREGATOR = 0xC4300B7CF0646F0Fe4C5B2ACFCCC4dCA1346f5d8;
  address public constant rsETH_LRT_ORACLE = 0x7781ae9B47FeCaCEAeCc4FcA8d0b6187E3eF9ba7;
  address public constant rsETH_ETH_AGGREGATOR = 0x99DAf760d2CFB770cc17e883dF45454FE421616b;
  address public constant EURC_PRICE_FEED = 0xDAe398520e2B67cd3f27aeF9Cf14D93D927f8250;
  address public constant EUR_PRICE_FEED = 0xc91D87E81faB8f93699ECf7Ee9B44D11e1D53F0F;
  address public constant LBTC_STAKE_ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;

  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BaseAssets.WETH_ORACLE,
            ratioProviderAddress: weETH_eETH_AGGREGATOR,
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1038264880178601326,
              snapshotTimestamp: 1715620171, // 13th of May 2024
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
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BaseAssets.WETH_ORACLE,
            ratioProviderAddress: ezETH_ETH_AGGREGATOR,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1029613402295302804,
              snapshotTimestamp: 1733389347, // 2024-12-05
              maxYearlyRatioGrowthPercent: 10_89
            })
          })
        )
      );
  }

  function rsETHCLAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BaseAssets.WETH_ORACLE,
            ratioProviderAddress: rsETH_ETH_AGGREGATOR,
            pairDescription: 'Capped rsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_036271920052097966,
              snapshotTimestamp: 1738837347, // Feb-06-2025
              maxYearlyRatioGrowthPercent: 9_83
            })
          })
        )
      );
  }

  function EURCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(EURPriceCapAdapterStable).creationCode,
        abi.encode(
          IEURPriceCapAdapterStable.CapAdapterStableParamsEUR({
            aclManager: AaveV3Base.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(EURC_PRICE_FEED),
            baseToUsdAggregator: IChainlinkAggregator(EUR_PRICE_FEED),
            adapterDescription: 'Capped EURC/USD',
            priceCapRatio: int256(1.04 * 1e8),
            ratioDecimals: 8
          })
        )
      );
  }

  function lBTCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(LBTCPriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkBase.BTC_USD,
            ratioProviderAddress: LBTC_STAKE_ORACLE,
            pairDescription: 'Capped LBTC / BTC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_000000000000000000,
              snapshotTimestamp: 1750031153, // Jun-15-2025
              maxYearlyRatioGrowthPercent: 2_00
            })
          })
        )
      );
  }

  function syrupUSDCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: AaveV3BaseAssets.USDC_ORACLE,
            ratioProviderAddress: ChainlinkBase.syrupUSDC_USDC_Exchange_Rate,
            pairDescription: 'Capped SyrupUSDC / USDC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_141275955119667166,
              snapshotTimestamp: 1765541747, // Dec-12-2025
              maxYearlyRatioGrowthPercent: 8_04
            })
          })
        )
      );
  }
}

contract DeployLBTCBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.lBTCAdapterCode());
  }
}

contract DeployWeEthBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.weETHAdapterCode());
  }
}

contract DeployEzEthBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.ezETHAdapterCode());
  }
}

contract DeployRsETHBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.rsETHCLAdapterCode());
  }
}

contract DeployEURCBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.EURCAdapterCode());
  }
}

contract DeploySyrupUSDCBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.syrupUSDCAdapterCode());
  }
}
