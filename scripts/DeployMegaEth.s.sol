// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {MegaEthScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3MegaEth} from 'aave-address-book/AaveV3MegaEth.sol';

import {OneUSDFixedAdapter} from '../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IPriceCapAdapter, IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeMegaEth {
  address public constant BTC_USD_PRICE_FEED = 0xc6E3007B597f6F5a6330d43053D1EF73cCbbE721;
  address public constant ETH_USD_PRICE_FEED = 0xcA4e254D95637DE95E2a2F79244b03380d697feD;
  address public constant USDT_USD_PRICE_FEED = 0xA533f4164d8d9F8C3995FC83F2f022a622d1765D;
  address public constant wstETH_stETH_Exchange_Rate = 0xe020C0Abc50E6581A95cb79Ff1021728C9Ec0640;
  address public constant rsETH_ETH_Exchange_Rate = 0x1de97D40C58AA167b7eaEB922f9801bcd0B12781;
  address public constant ezETH_ETH_Exchange_Rate = 0x6d924215a8A8e48651F774312b7bA549c1E09df9;

  function USDT0AdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(USDT_USD_PRICE_FEED),
            adapterDescription: 'Capped USDT/USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function oneUSDFixedAdapterCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(OneUSDFixedAdapter).creationCode);
  }

  function wstEthAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: wstETH_stETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 7 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_224765524214769828,
              snapshotTimestamp: 1768797011, // 19 Jan 2026 (Block: 6000000)
              maxYearlyRatioGrowthPercent: 9_68
            })
          })
        )
      );
  }

  function wrsEthAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: rsETH_ETH_Exchange_Rate,
            pairDescription: 'Capped wrsETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_062963262677405278,
              snapshotTimestamp: 1768797011, // 19 Jan 2026 (Block: 6000000)
              maxYearlyRatioGrowthPercent: 6_67
            })
          })
        )
      );
  }

  function ezEthAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: ezETH_ETH_Exchange_Rate,
            pairDescription: 'Capped ezETH / ETH / USD',
            minimumSnapshotDelay: 14 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 1_069243893690457003,
              snapshotTimestamp: 1768197011, // 12 Jan 2026 (Block: 5400000)
              maxYearlyRatioGrowthPercent: 10_89
            })
          })
        )
      );
  }
}

contract DeployUSDT0MegaEth is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaEth.USDT0AdapterCode());
  }
}

contract DeployOneUSDFixedAdapterMegaEth is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaEth.oneUSDFixedAdapterCode());
  }
}

contract DeployWstEthMegaEth is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaEth.wstEthAdapterCode());
  }
}

contract DeployWrsEthMegaEth is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaEth.wrsEthAdapterCode());
  }
}

contract DeployEzEthMegaEth is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaEth.ezEthAdapterCode());
  }
}
