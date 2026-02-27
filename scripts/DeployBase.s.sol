// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {BaseScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Base, AaveV3BaseAssets} from 'aave-address-book/AaveV3Base.sol';
import {ChainlinkBase} from 'aave-address-book/ChainlinkBase.sol';

import {EURPriceCapAdapterStable, IEURPriceCapAdapterStable, IChainlinkAggregator} from '../src/contracts/misc-adapters/EURPriceCapAdapterStable.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {CLRatePriceCapAdapter, IPriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {LBTCPriceCapAdapter} from '../src/contracts/lst-adapters/LBTCPriceCapAdapter.sol';

library CapAdaptersCodeBase {
  address public constant LBTC_STAKE_ORACLE = 0x1De9fcfeDF3E51266c188ee422fbA1c7860DA0eF;
  address public constant USDC_SVR_CAPPED_ADAPTER = 0xf52D010c7d4ecBfda92c2509900593CE34535D86;

  function weETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkBase.AAVE_SVR_WEETH__EETH_Exchange_Rate,
            pairDescription: 'Capped weETH / eETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_088379838933126642,
              snapshotTimestamp: 1771307347, // Feb-17-2026 (block: 42259000)
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
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkBase.AAVE_SVR_EZETH__ETH_Exchange_Rate,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_071514982303582791,
              snapshotTimestamp: 1770691347, // Feb-10-2026 (block: 41951000)
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
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkBase.AAVE_SVR_rsETH__ETH_Exchange_Rate,
            pairDescription: 'Capped rsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_064691728347193357,
              snapshotTimestamp: 1770691347, // Feb-10-2026 (block: 41951000)
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
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkBase.AAVE_SVR_EURC__USD),
            baseToUsdAggregator: IChainlinkAggregator(ChainlinkBase.EUR__USD),
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
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_BTC__USD,
            ratioProviderAddress: LBTC_STAKE_ORACLE,
            pairDescription: 'Capped LBTC / BTC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_003041079211609094,
              snapshotTimestamp: 1771307347, // Feb-17-2026 (block: 42259000)
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
            baseAggregatorAddress: USDC_SVR_CAPPED_ADAPTER,
            ratioProviderAddress: ChainlinkBase.syrupUSDC_USDC_Exchange_Rate,
            pairDescription: 'Capped SyrupUSDC / USDC / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_151861177118403071,
              snapshotTimestamp: 1771307347, // Feb-17-2026 (block: 42259000)
              maxYearlyRatioGrowthPercent: 8_04
            })
          })
        )
      );
  }

  function cbETHAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkBase.cbETH_ETH_Exchange_Rate,
            pairDescription: 'Capped cbETH / ETH / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_123263823685699828,
              snapshotTimestamp: 1771307347, // Feb-17-2026 (block: 42259000)
              maxYearlyRatioGrowthPercent: 8_12
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
            aclManager: AaveV3Base.ACL_MANAGER,
            baseAggregatorAddress: ChainlinkBase.AAVE_SVR_ETH__USD,
            ratioProviderAddress: ChainlinkBase.AAVE_SVR_WSTETH__STETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_227182231483433137,
              snapshotTimestamp: 1771307347, // Feb-17-2026 (block: 42259000)
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
            aclManager: AaveV3Base.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(ChainlinkBase.AAVE_SVR_USDC__USD),
            adapterDescription: 'Capped USDC/USD',
            priceCap: int256(1.04 * 1e8)
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

contract DeployCbETHBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.cbETHAdapterCode());
  }
}

contract DeployWstETHBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.wstETHAdapterCode());
  }
}

contract DeployUSDCBase is BaseScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeBase.USDCAdapterCode());
  }
}
