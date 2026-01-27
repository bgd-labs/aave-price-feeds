// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {MegaEthScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3MegaEth} from 'aave-address-book/AaveV3MegaEth.sol';

import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';
import {PriceCapAdapterStable, IPriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IPriceCapAdapter, IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';

library CapAdaptersCodeMegaETH {
  address public constant BTC_USD_PRICE_FEED = 0xc6E3007B597f6F5a6330d43053D1EF73cCbbE721;
  address public constant ETH_USD_PRICE_FEED = 0xC3E01CC87A99A48081282F6566E1286fccC80d36;
  address public constant USDT_USD_PRICE_FEED = 0x0683E2424d1088C70f86B2cB788eAA8cf7a82AF6;
  address public constant LBTC_BTC_Exchange_Rate = 0x132ACc50CF438733c64210e6FE50764E9d25E01f;
  address public constant wstETH_stETH_Exchange_Rate = 0xe020C0Abc50E6581A95cb79Ff1021728C9Ec0640;
  address public constant rsETH_ETH_Exchange_Rate = 0x1de97D40C58AA167b7eaEB922f9801bcd0B12781;

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

  function LBTCAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(CLRatePriceCapAdapter).creationCode,
        abi.encode(
          IPriceCapAdapter.CapAdapterParams({
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: BTC_USD_PRICE_FEED,
            ratioProviderAddress: LBTC_BTC_Exchange_Rate,
            pairDescription: 'Capped LBTC / BTC / USD',
            minimumSnapshotDelay: 0 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 0,
              snapshotTimestamp: 0,
              maxYearlyRatioGrowthPercent: 0
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
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: wstETH_stETH_Exchange_Rate,
            pairDescription: 'Capped wstETH / stETH(ETH) / USD',
            minimumSnapshotDelay: 0 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 0,
              snapshotTimestamp: 0,
              maxYearlyRatioGrowthPercent: 0
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
            aclManager: AaveV3MegaEth.ACL_MANAGER,
            baseAggregatorAddress: ETH_USD_PRICE_FEED,
            ratioProviderAddress: rsETH_ETH_Exchange_Rate,
            pairDescription: 'Capped rsETH / ETH / USD',
            minimumSnapshotDelay: 0 days,
            priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
              snapshotRatio: 0,
              snapshotTimestamp: 0,
              maxYearlyRatioGrowthPercent: 0
            })
          })
        )
      );
  }
}

contract DeployUSDT0MegaETH is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaETH.USDT0AdapterCode());
  }
}

contract DeployLBTCMegaETH is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaETH.LBTCAdapterCode());
  }
}
contract DeployWstETHMegaETH is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaETH.wstETHAdapterCode());
  }
}
contract DeployRsETHMegaETH is MegaEthScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeMegaETH.rsETHAdapterCode());
  }
}
