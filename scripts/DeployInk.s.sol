// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {InkScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3InkWhitelabel, AaveV3InkWhitelabelAssets} from 'aave-address-book/AaveV3InkWhitelabel.sol';
import {FixedPriceAdapter} from '../src/contracts/misc-adapters/FixedPriceAdapter.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/PriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {IPriceCapAdapter} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeInk {
  address public constant USDT_PRICE_FEED = 0x176A9536feaC0340de9f9811f5272E39E80b424f;
  address public constant USDC_PRICE_FEED = 0xCffB7b219A6Ee67468B02fE4e34E33Fd393c76Ff;
  address public constant ETH_PRICE_FEED = 0x163131609562E578754aF12E998635BfCa56712C;
  address public constant WrsETH_ETH_PRICE_FEED = 0x800Ca870416CDFEf77991036B8e1f2E51623996E;
  address public constant WsTETH_stETH_PRICE_FEED = 0x0eA85E34b26ff769e63c24776baBA60782446166;
  address public constant WeETH_eETH_PRICE_FEED = 0x15D2126ab8a9E88249d99A4bAf7d080BF3AEAb8A;
  address public constant EzETH_ETH_PRICE_FEED = 0x7AebbD32bDd12E8fd5bB5ff6D7F2230c86dfC1fF;
  address public constant sUSDe_USDe_Exchange_rate = 0x02c7c0CCE407299ABB0B1aaA481DBe23de7a1dBc;

  function USDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDT_PRICE_FEED),
            adapterDescription: 'Capped USDT/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function USDGAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(address(AaveV3InkWhitelabel.ACL_MANAGER), 8, int256(1 * 1e8), 'Fixed USDG/USD')
      );
  }

  function USDCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDC_PRICE_FEED),
            adapterDescription: 'Capped USDC/USD',
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
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            baseAggregatorAddress: ETH_PRICE_FEED,
            ratioProviderAddress: WrsETH_ETH_PRICE_FEED,
            pairDescription: 'Capped wrsETH / ETH / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_058120958440253568,
              snapshotTimestamp: 1762858813, // Nov 11 2025
              maxYearlyRatioGrowthPercent: 9_83
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
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            baseAggregatorAddress: ETH_PRICE_FEED,
            ratioProviderAddress: WsTETH_stETH_PRICE_FEED,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_218828057399501522,
              snapshotTimestamp: 1762847219, // Nov 11 2025
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            baseAggregatorAddress: ETH_PRICE_FEED,
            ratioProviderAddress: WeETH_eETH_PRICE_FEED, // This price feed use 8 decimals
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_08120571, // Nov 11 2025
              snapshotTimestamp: 1762847219,
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
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            baseAggregatorAddress: ETH_PRICE_FEED,
            ratioProviderAddress: EzETH_ETH_PRICE_FEED,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_064510642291841280,
              snapshotTimestamp: 1762858813, // Nov 11 2025
              maxYearlyRatioGrowthPercent: 10_89
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
            aclManager: AaveV3InkWhitelabel.ACL_MANAGER,
            baseAggregatorAddress: AaveV3InkWhitelabelAssets.USDT_ORACLE,
            ratioProviderAddress: sUSDe_USDe_Exchange_rate,
            pairDescription: 'Capped sUSDe / USDT / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_217396774850780700, // snapshot from mainnet
              snapshotTimestamp: 1769137643, // Jan-23-2026 (block: 24294700)
              maxYearlyRatioGrowthPercent: 15_19
            })
          })
        )
      );
  }
}

contract DeployUSDGInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.USDGAdapterCode());
  }
}

contract DeployUSDTInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.USDTAdapterCode());
  }
}

contract DeployUSDCInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.USDCAdapterCode());
  }
}

contract DeployWRsETHInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.wrsETHAdapterCode());
  }
}

contract DeployWStETHInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.wstETHAdapterCode());
  }
}

contract DeployWeETHInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.weETHAdapterCode());
  }
}

contract DeployEzETHInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.ezETHAdapterCode());
  }
}

contract DeploySUSDeInk is InkScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeInk.sUSDeAdapterCode());
  }
}
