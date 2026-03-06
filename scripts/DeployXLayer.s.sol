// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {XLayerScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3XLayer, AaveV3XLayerAssets} from 'aave-address-book/AaveV3XLayer.sol';
import {MiscXLayer} from 'aave-address-book/MiscXLayer.sol';

import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {OneUSDFixedAdapter} from '../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';
import {IChainlinkAggregator} from '../src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from '../src/interfaces/IPriceCapAdapterStable.sol';

library CapAdaptersCodeXLayer {
  address public constant CL_USDT_USD_FEED = 0xb928a0678352005a2e51F614efD0b54C9830dB80;

  function USDTAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(PriceCapAdapterStable).creationCode,
        abi.encode(
          IPriceCapAdapterStable.CapAdapterStableParams({
            aclManager: AaveV3XLayer.ACL_MANAGER,
            assetToUsdAggregator: IChainlinkAggregator(CL_USDT_USD_FEED),
            adapterDescription: 'Capped USDT / USD',
            priceCap: int256(1.04 * 1e8)
          })
        )
      );
  }

  function oneUSDFixedAdapterCode() internal pure returns (bytes memory) {
    return abi.encodePacked(type(OneUSDFixedAdapter).creationCode);
  }
}

contract DeployUSDT is XLayerScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeXLayer.USDTAdapterCode());
  }
}

contract DeployOneUsd is XLayerScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodeXLayer.oneUSDFixedAdapterCode());
  }
}
