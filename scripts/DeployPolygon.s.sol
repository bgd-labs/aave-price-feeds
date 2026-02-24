// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {PolygonScript} from 'solidity-utils/contracts/utils/ScriptUtils.sol';
import {AaveV3Polygon} from 'aave-address-book/AaveV3Polygon.sol';
import {FixedPriceAdapter} from '../src/contracts/misc-adapters/FixedPriceAdapter.sol';

library CapAdaptersCodePolygon {
  function fixedDpiUsdAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(address(AaveV3Polygon.ACL_MANAGER), 8, int256(102 * 1e8), 'Fixed DPI/USD')
      );
  }

  function fixedDpiEthAdapterCode() internal pure returns (bytes memory) {
    return
      abi.encodePacked(
        type(FixedPriceAdapter).creationCode,
        abi.encode(address(AaveV3Polygon.ACL_MANAGER), 18, int256(0.022767 * 1e18), 'Fixed DPI/ETH')
      );
  }
}

contract DeployFixedDpiUsdPolygon is PolygonScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodePolygon.fixedDpiUsdAdapterCode());
  }
}

contract DeployFixedDpiEthPolygon is PolygonScript {
  function run() external broadcast {
    GovV3Helpers.deployDeterministic(CapAdaptersCodePolygon.fixedDpiEthAdapterCode());
  }
}
