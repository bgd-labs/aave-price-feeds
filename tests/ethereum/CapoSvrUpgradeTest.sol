// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {AaveV3Ethereum, AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV3EthereumLidoAssets} from 'aave-address-book/AaveV3EthereumLido.sol';
import {IPriceCapAdapter} from '../../src/interfaces/IPriceCapAdapter.sol';
import {IPriceCapAdapterStable} from '../../src/interfaces/IPriceCapAdapterStable.sol';

import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';

library CAPO_SVR {
  // https://etherscan.io/address/0x87625393534d5C102cADB66D37201dF24cc26d4C
  address public constant weETH = 0x87625393534d5C102cADB66D37201dF24cc26d4C;
  // https://etherscan.io/address/0x2b86D519eF34f8Adfc9349CDeA17c09Aa9dB60E2
  address public constant osETH = 0x2b86D519eF34f8Adfc9349CDeA17c09Aa9dB60E2;
  // https://etherscan.io/address/0xd7b163B671f8cE9379DF8Ff7F75fA72Ccec1841c
  address public constant ETHx = 0xd7b163B671f8cE9379DF8Ff7F75fA72Ccec1841c;
  // https://etherscan.io/address/0x7292C95A5f6A501a9c4B34f6393e221F2A0139c3
  address public constant rsETH = 0x7292C95A5f6A501a9c4B34f6393e221F2A0139c3;
  // https://etherscan.io/address/0xe1D97bF61901B075E9626c8A2340a7De385861Ef
  address public constant wstETH = 0xe1D97bF61901B075E9626c8A2340a7De385861Ef;
  // https://etherscan.io/address/0x6929706c42d637DF5Ebf7F0BcfF2aF47F84Ea69D
  address public constant rETH = 0x6929706c42d637DF5Ebf7F0BcfF2aF47F84Ea69D;
  // https://etherscan.io/address/0x889399C34461b25d70d43931e6cE9E40280E617B
  address public constant cbETH = 0x889399C34461b25d70d43931e6cE9E40280E617B;
  // https://etherscan.io/address/0x3f73F03aa83B2A48ed27E964eD0fDb590332095B
  address public constant USDC = 0x3f73F03aa83B2A48ed27E964eD0fDb590332095B;
  // https://etherscan.io/address/0x1D8217ef16c00A5717F3f384F41fd010FfCc0588
  address public constant USDT = 0x1D8217ef16c00A5717F3f384F41fd010FfCc0588;
  // https://etherscan.io/address/0x577C217cB5b1691A500D48aA7F69346409cFd668
  address public constant eBTC = 0x577C217cB5b1691A500D48aA7F69346409cFd668;
  // https://etherscan.io/address/0xF3d49021fF3bbBFDfC1992A4b09E5D1d141D044C
  address public constant ezETH = 0xF3d49021fF3bbBFDfC1992A4b09E5D1d141D044C;
  // https://etherscan.io/address/0xDaa4B74C6bAc4e25188e64ebc68DB5050b690cAc
  address public constant WBTC = 0xDaa4B74C6bAc4e25188e64ebc68DB5050b690cAc;
}

struct Adapters {
  address current;
  address svr;
}

contract CapoSvrUpgradeTest is Test {
  Adapters[] public lsts;
  Adapters[] public stables;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 22376115);
    _setAdapters();
  }

  function test_adapters_parameters_remained_equal() public view {
    for (uint256 i = 0; i < lsts.length; i++) {
      IPriceCapAdapter current = IPriceCapAdapter(lsts[i].current);
      IPriceCapAdapter svr = IPriceCapAdapter(lsts[i].svr);
      _assertLstAdapterParams(current, svr);
    }

    for (uint256 i = 0; i < stables.length; i++) {
      IPriceCapAdapterStable current = IPriceCapAdapterStable(stables[i].current);
      IPriceCapAdapterStable svr = IPriceCapAdapterStable(stables[i].svr);
      _assertStableAdapterParams(current, svr);
    }
  }

  function test_lsts_base_aggregator_is_svr_oracle() public view {
    for (uint256 i = 0; i < lsts.length; i++) {
      address baseAggregator = address(IPriceCapAdapter(lsts[i].svr).BASE_TO_USD_AGGREGATOR());

      if (lsts[i].svr == CAPO_SVR.eBTC) {
        assertEq(baseAggregator, ChainlinkEthereum.SVR_BTC__USD);
      } else {
        assertEq(baseAggregator, ChainlinkEthereum.SVR_ETH__USD);
      }
    }
  }

  function test_stables_base_aggregator_is_svr_oracle() public view {
    for (uint256 i = 0; i < stables.length; i++) {
      address baseAggregator = address(
        IPriceCapAdapterStable(stables[i].svr).ASSET_TO_USD_AGGREGATOR()
      );

      if (stables[i].svr == CAPO_SVR.USDC) {
        assertEq(baseAggregator, ChainlinkEthereum.SVR_USDC__USD);
      } else {
        assertEq(baseAggregator, ChainlinkEthereum.SVR_USDT__USD);
      }
    }
  }

  function test_clSync_wbtc_parameters() public view {
    CLSynchronicityPriceAdapterPegToBase currentWBTC = CLSynchronicityPriceAdapterPegToBase(
      AaveV3EthereumAssets.WBTC_ORACLE
    );
    CLSynchronicityPriceAdapterPegToBase svrWBTC = CLSynchronicityPriceAdapterPegToBase(
      CAPO_SVR.WBTC
    );

    // parameters
    assertEq(address(currentWBTC.ASSET_TO_PEG()), address(svrWBTC.ASSET_TO_PEG()));
    assertEq(currentWBTC.DENOMINATOR(), svrWBTC.DENOMINATOR());
    assertEq(currentWBTC.DECIMALS(), svrWBTC.DECIMALS());

    // current wbtc doesn't have `description()` method
    assertEq(svrWBTC.description(), 'wBTC/BTC/USD');

    // svr oracle
    assertEq(address(svrWBTC.PEG_TO_BASE()), ChainlinkEthereum.SVR_BTC__USD);
  }

  function _assertLstAdapterParams(IPriceCapAdapter current, IPriceCapAdapter svr) internal view {
    // immutables
    assertEq(current.DECIMALS(), svr.DECIMALS());
    assertEq(current.RATIO_DECIMALS(), svr.RATIO_DECIMALS());
    assertEq(current.RATIO_PROVIDER(), svr.RATIO_PROVIDER());
    assertEq(current.MINIMUM_SNAPSHOT_DELAY(), svr.MINIMUM_SNAPSHOT_DELAY());

    assertEq(current.description(), svr.description());
    assertEq(current.getMaxRatioGrowthPerSecond(), svr.getMaxRatioGrowthPerSecond());
    assertEq(current.getMaxYearlyGrowthRatePercent(), svr.getMaxYearlyGrowthRatePercent());
    assertEq(current.getSnapshotRatio(), svr.getSnapshotRatio());
    assertEq(current.getSnapshotTimestamp(), svr.getSnapshotTimestamp());
    assertEq(current.getRatio(), svr.getRatio());

    // rsETH was listed first on Lido instance, and as it is on core now, we set the core ACL address.
    if (address(svr) == CAPO_SVR.rsETH) {
      assertEq(address(svr.ACL_MANAGER()), address(AaveV3Ethereum.ACL_MANAGER));
    } else {
      assertEq(address(current.ACL_MANAGER()), address(svr.ACL_MANAGER()));
    }
  }

  function _assertStableAdapterParams(
    IPriceCapAdapterStable current,
    IPriceCapAdapterStable svr
  ) internal view {
    assertEq(current.decimals(), svr.decimals());
    assertEq(address(current.ACL_MANAGER()), address(svr.ACL_MANAGER()));

    if (address(svr) == CAPO_SVR.USDC) {
      assertEq(svr.description(), 'Capped USDC / USD'); // added spaces ._.
    } else {
      assertEq(svr.description(), 'Capped USDT / USD');
    }
  }

  function _setAdapters() internal {
    lsts.push(Adapters({current: AaveV3EthereumAssets.weETH_ORACLE, svr: CAPO_SVR.weETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.osETH_ORACLE, svr: CAPO_SVR.osETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.ETHx_ORACLE, svr: CAPO_SVR.ETHx}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.rsETH_ORACLE, svr: CAPO_SVR.rsETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.wstETH_ORACLE, svr: CAPO_SVR.wstETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.rETH_ORACLE, svr: CAPO_SVR.rETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.cbETH_ORACLE, svr: CAPO_SVR.cbETH}));
    lsts.push(Adapters({current: AaveV3EthereumLidoAssets.ezETH_ORACLE, svr: CAPO_SVR.ezETH}));
    lsts.push(Adapters({current: AaveV3EthereumAssets.eBTC_ORACLE, svr: CAPO_SVR.eBTC}));
    stables.push(Adapters({current: AaveV3EthereumAssets.USDC_ORACLE, svr: CAPO_SVR.USDC}));
    stables.push(Adapters({current: AaveV3EthereumAssets.USDT_ORACLE, svr: CAPO_SVR.USDT}));
  }
}
