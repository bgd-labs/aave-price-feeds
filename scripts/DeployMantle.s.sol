// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {MantleScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Mantle} from 'aave-address-book/AaveV3Mantle.sol';
import {ChainlinkMantle} from 'aave-address-book/ChainlinkMantle.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/PriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {IPriceCapAdapter} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeMantle {
  // These aggregators are not yet in the Chainlink address-book
  address public constant rsETH_ETH_Exchange_rate = 0xAa7B3679db156d3773620eBce98E38Cd87544C0e;
  address public constant sUSDe_USDe_Exchange_rate = 0x1D28137b7695d1Dcd122E5Bf0ce7eE92360e83b7;
  address public constant syrupUSDT_USDT_Exchange_rate = 0xdDEaeAdF319bd363120Af02fBdb1e2C5A3Ce172a;
  address public constant USDT_Stable_Adapter = 0xFA5dEcEd7cdCEAB065addd0E32D9527ABd1069Ee;

  function USDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Mantle.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkMantle.USDT__USD),
            adapterDescription: 'Capped USDT/USD',
            priceCap: int256(1.04 * 1e8)
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
            aclManager: AaveV3Mantle.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkMantle.USDC__USD),
            adapterDescription: 'Capped USDC/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function syrupUSDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Mantle.ACL_MANAGER,
            baseAggregatorAddress: USDT_Stable_Adapter,
            ratioProviderAddress: syrupUSDT_USDT_Exchange_rate,
            pairDescription: 'Capped SyrupUSDT / USDT / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_110788277783283832, // snapshot from mainnet (block: 24180000)
              snapshotTimestamp: 1767755099, // Jan-07-2026
              maxYearlyRatioGrowthPercent: 8_45
            })
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
            aclManager: AaveV3Mantle.ACL_MANAGER,
            baseAggregatorAddress: USDT_Stable_Adapter,
            ratioProviderAddress: sUSDe_USDe_Exchange_rate,
            pairDescription: 'Capped sUSDe / USDT / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_213777113888938853, // snapshot from mainnet
              snapshotTimestamp: 1767152639, // Dec-31-2025 (block: 24130000)
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
            aclManager: AaveV3Mantle.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkMantle.ETH__USD,
            ratioProviderAddress: rsETH_ETH_Exchange_rate,
            pairDescription: 'Capped wrsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_061649883886412906, // snapshot from mainnet
              snapshotTimestamp: 1767152639, // Dec-31-2025 (block: 24130000)
              maxYearlyRatioGrowthPercent: 6_67
            })
          })
        )
      );
  }
}

contract DeployUSDTMantle is MantleScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMantle.USDTAdapterCode());
  }
}

contract DeployUSDCMantle is MantleScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMantle.USDCAdapterCode());
  }
}

contract DeploySyrupUSDTMantle is MantleScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMantle.syrupUSDTAdapterCode());
  }
}

contract DeploySUSDeMantle is MantleScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMantle.sUSDeAdapterCode());
  }
}

contract DeployWrsETHMantle is MantleScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMantle.wrsETHAdapterCode());
  }
}
