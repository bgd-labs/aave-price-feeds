// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {ArbitrumScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Arbitrum, AaveV3ArbitrumAssets} from 'aave-address-book/AaveV3Arbitrum.sol';
import {ChainlinkArbitrum} from 'aave-address-book/ChainlinkArbitrum.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/PriceCapAdapterStable.sol';

import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';

library CapAdaptersCodeArbitrum {
  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkArbitrum.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkArbitrum.weETH__eETH_Exchange_Rate,
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_088393341385115561,
              snapshotTimestamp: 1771345811, // Feb-17-2026 (block: 433105000)
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
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkArbitrum.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkArbitrum.ezETH__ETH_Exchange_Rate,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_071564937164950348,
              snapshotTimestamp: 1770747589, // Feb-10-2026 (block: 430704000)
              maxYearlyRatioGrowthPercent: 10_89
            })
          })
        )
      );
  }

  function rsETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkArbitrum.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkArbitrum.rsETH__ETH_Exchange_Rate,
            pairDescription: 'Capped rsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_064743064023132384,
              snapshotTimestamp: 1770747589, // Feb-10-2026 (block: 430704000)
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
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkArbitrum.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkArbitrum.wstETH_stETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_227259738293014024,
              snapshotTimestamp: 1771345811, // Feb-17-2026 (block: 433105000)
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function rETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkArbitrum.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkArbitrum.rETH_ETH_Exchange_Rate,
            pairDescription: 'Capped rETH / ETH / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_157667799842276298,
              snapshotTimestamp: 1771345811, // Feb-17-2026 (block: 433105000)
              maxYearlyRatioGrowthPercent: 9_30
            })
          })
        )
      );
  }

  function FRAXAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkArbitrum.AAVE_SVR_FRAX__USD),
            adapterDescription: 'Capped FRAX/USD',
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
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkArbitrum.AAVE_SVR_USDT__USD),
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
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkArbitrum.AAVE_SVR_USDC__USD),
            adapterDescription: 'Capped USDC/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function DAIAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkArbitrum.AAVE_SVR_DAI__USD),
            adapterDescription: 'Capped DAI/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function LUSDAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3Arbitrum.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkArbitrum.AAVE_SVR_LUSD__USD),
            adapterDescription: 'Capped LUSD/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }
}

contract DeployWeEthArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.weETHAdapterCode());
  }
}

contract DeployEzEthArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.ezETHAdapterCode());
  }
}

contract DeployRsETHArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.rsETHAdapterCode());
  }
}

contract DeployWstETHArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.wstETHAdapterCode());
  }
}

contract DeployRETHArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.rETHAdapterCode());
  }
}

contract DeployFRAXArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.FRAXAdapterCode());
  }
}

contract DeployUSDTArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.USDTAdapterCode());
  }
}

contract DeployUSDCArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.USDCAdapterCode());
  }
}

contract DeployDAIArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.DAIAdapterCode());
  }
}

contract DeployLUSDArbitrum is ArbitrumScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeArbitrum.LUSDAdapterCode());
  }
}
