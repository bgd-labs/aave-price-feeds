// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {AvalancheScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Avalanche, AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {ChainlinkAvalanche} from 'aave-address-book/ChainlinkAvalanche.sol';

import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from '../src/interfaces/IPriceCapAdapterStable.sol';

library CapAdaptersCodeAvalanche {
  address public constant AUSD_PRICE_FEED = 0x5C2d58627Fbe746f5ea24Ef6D618f09f8e3f0122;
  address public constant sUSDe_USDe_AGGREGATOR = 0xb7441BBD0298aaeF4f2BbD40E8025Cf59cA6E8D5;

  function AUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Avalanche.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(AUSD_PRICE_FEED),
            adapterDescription: 'Capped AUSD / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function sUSDeAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Avalanche.ACL_MANAGER,
            baseAggregatorAddress: AaveV3AvalancheAssets.USDt_ORACLE,
            ratioProviderAddress: sUSDe_USDe_AGGREGATOR,
            pairDescription: 'Capped sUSDe / USDe / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_193972665854975048,
              snapshotTimestamp: 1756871339, // 3-SEPT-2025
              maxYearlyRatioGrowthPercent: 15_19
            })
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
            aclManager: AaveV3Avalanche.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkAvalanche.ETH__USD,
            ratioProviderAddress: ChainlinkAvalanche.WRSETH_ETH_Exchange_Rate,
            pairDescription: 'Capped wrsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_056504040539383578,
              snapshotTimestamp: 1760911946, // Oct-19-2025
              maxYearlyRatioGrowthPercent: 9_83
            })
          })
        )
      );
  }
}

contract DeployAUSDAvalanche is AvalancheScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeAvalanche.AUSDAdapterCode());
  }
}

contract DeploySUSDeAvalanche is AvalancheScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeAvalanche.sUSDeAdapterCode());
  }
}

contract DeployWrsETHeAvalanche is AvalancheScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeAvalanche.wrsETHAdapterCode());
  }
}
