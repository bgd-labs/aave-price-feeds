// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';

import {AaveV3EthereumAssets} from 'aave-address-book/AaveV3Ethereum.sol';
import {AaveV2EthereumAssets} from 'aave-address-book/AaveV2Ethereum.sol';
import {AaveV3AvalancheAssets} from 'aave-address-book/AaveV3Avalanche.sol';
import {ChainlinkAvalanche} from 'aave-address-book/ChainlinkAvalanche.sol';
import {AaveV3GnosisAssets} from 'aave-address-book/AaveV3Gnosis.sol';
import {MiscEthereum} from 'aave-address-book/MiscEthereum.sol';
import {MiscArbitrum} from 'aave-address-book/MiscArbitrum.sol';
import {MiscBase} from 'aave-address-book/MiscBase.sol';
import {MiscGnosis} from 'aave-address-book/MiscGnosis.sol';
import {MiscOptimism} from 'aave-address-book/MiscOptimism.sol';
import {MiscPolygon} from 'aave-address-book/MiscPolygon.sol';
import {ChainlinkBase} from 'aave-address-book/ChainlinkBase.sol';

import {ICbEthRateProvider} from 'cl-synchronicity-price-adapter/interfaces/ICbEthRateProvider.sol';
import {IrETH} from 'cl-synchronicity-price-adapter/interfaces/IrETH.sol';
import {IPot} from 'cl-synchronicity-price-adapter/interfaces/IPot.sol';
import {IStETH} from 'cl-synchronicity-price-adapter/interfaces/IStETH.sol';
import {IMaticRateProvider} from 'cl-synchronicity-price-adapter/interfaces/IMaticRateProvider.sol';
import {IERC4626} from 'forge-std/interfaces/IERC4626.sol';
import {IChainlinkAggregator} from 'cl-synchronicity-price-adapter/interfaces/IChainlinkAggregator.sol';
import {ISAvax} from '../../src/interfaces/ISAvax.sol';
import {IStEUR} from '../../src/interfaces/IStEUR.sol';
import {IWeEth} from '../../src/interfaces/IWeEth.sol';
import {IOsTokenVaultController} from '../../src/interfaces/IOsTokenVaultController.sol';
import {IEthX} from '../../src/interfaces/IEthX.sol';
import {IEzETHRestakeManager, IEzEthToken} from '../../src/interfaces/IEzETH.sol';
import {IRsETH} from '../../src/interfaces/IRsETH.sol';
import {IBNBx} from '../../src/interfaces/IBNBx.sol';
import {IRsETHL2} from '../../src/interfaces/IRsETHL2.sol';
import {IEBTC} from '../../src/interfaces/IEBTC.sol';
import {IStS} from '../../src/interfaces/IStS.sol';
import {IMaplePool} from '../../src/interfaces/IMaplePool.sol';

import {CapAdaptersCodeEthereum} from '../../scripts/DeployEthereum.s.sol';
import {CapAdaptersCodeArbitrum} from '../../scripts/DeployArbitrum.s.sol';
import {CapAdaptersCodeBase} from '../../scripts/DeployBase.s.sol';
import {CapAdaptersCodeScroll} from '../../scripts/DeployScroll.s.sol';
import {CapAdaptersCodeBNB} from '../../scripts/DeployBnb.s.sol';
import {CapAdaptersCodeZkSync} from '../../scripts/DeployZkSync.s.sol';
import {CapAdaptersCodeLinea} from '../../scripts/DeployLinea.s.sol';
import {CapAdaptersCodeSonic} from '../../scripts/DeploySonic.s.sol';
import {CapAdaptersCodePlasma} from '../../scripts/DeployPlasma.s.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';

contract ExchangeRatesEth is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), (23774600)); // Nov 11 2025
  }

  function test_getExchangeRate() public view {
    // uint256 cbEthRate = ICbEthRateProvider(AaveV3EthereumAssets.cbETH_UNDERLYING).exchangeRate();
    // uint256 rEthRate = IrETH(AaveV3EthereumAssets.rETH_UNDERLYING).getExchangeRate();
    // uint256 sDaiRate = IPot(MiscEthereum.sDAI_POT).chi();
    uint256 wstEthRate = IStETH(AaveV2EthereumAssets.stETH_UNDERLYING).getPooledEthByShares(
      10 ** 18
    );
    // uint256 stEurRate = IStEUR(MiscEthereum.stEUR).convertToAssets(10 ** 18);
    uint256 weEthRate = IWeEth(CapAdaptersCodeEthereum.weETH).getRate();
    // uint256 osEthRate = IOsTokenVaultController(CapAdaptersCodeEthereum.osETH_VAULT_CONTROLLER)
    //   .convertToAssets(10 ** 18);
    // uint256 ethXRate = IEthX(CapAdaptersCodeEthereum.STADER_STAKE_POOLS_MANAGER).getExchangeRate();
    // uint256 sUSDeRate = IERC4626(CapAdaptersCodeEthereum.sUSDe).convertToAssets(10 ** 18);
    // uint256 sUSDSRate = IERC4626(CapAdaptersCodeEthereum.sUSDS).convertToAssets(10 ** 18);

    // (, , uint256 totalTVL) = IEzETHRestakeManager(CapAdaptersCodeEthereum.ezETH_RESTAKE_MANAGER)
    //   .calculateTVLs();
    // uint256 ezETHRate = ((totalTVL * 1 ether) /
    //   IEzETHRestakeManager(CapAdaptersCodeEthereum.ezETH_RESTAKE_MANAGER).ezETH().totalSupply());

    // uint256 rsETHRate = IRsETH(CapAdaptersCodeEthereum.rsETH_LRT_ORACLE).rsETHPrice();
    // uint256 eBTCRate = IEBTC(CapAdaptersCodeEthereum.eBTC_ACCOUNTANT).getRate();
    // uint256 eUSDeRate = IERC4626(CapAdaptersCodeEthereum.eUSDe).convertToAssets(10 ** 18);
    // uint256 tETHtoWstETH = IERC4626(CapAdaptersCodeEthereum.tETH).convertToAssets(10 ** 18);
    // uint256 tETHRate = IStETH(AaveV2EthereumAssets.stETH_UNDERLYING).getPooledEthByShares(
    //   tETHtoWstETH
    // );
    // uint256 syrupUSDCRate = IMaplePool(CapAdaptersCodeEthereum.syrupUSDC).convertToExitAssets(
    //   10 ** 18
    // );
    uint256 syrupUSDTRate = IMaplePool(CapAdaptersCodeEthereum.syrupUSDT).convertToExitAssets(
      10 ** 18
    );

    // console.log('cbEthRate', cbEthRate);
    // console.log('rEthRate', rEthRate);
    // console.log('sDaiRate', sDaiRate);
    console.log('wstEthRate', wstEthRate);
    // console.log('stEurRate', stEurRate);
    console.log('weEthRate', weEthRate);
    // console.log('osEthRate', osEthRate);
    // console.log('ethXRate', ethXRate);
    // console.log('sUSDe', sUSDeRate);
    // console.log('sUSDS', sUSDSRate);
    // console.log('ezETHRate', ezETHRate);
    // console.log('rsETHRate', rsETHRate);
    // console.log('eBTCRate', eBTCRate);
    // console.log('eUSDeRate', eUSDeRate);
    // console.log('tETHRate', tETHRate);
    // console.log('syrupUSDCRate', syrupUSDCRate);
    // console.log('syrupUSDTRate', syrupUSDTRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRatesArbitrum is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 311775777); // 2025-03-03
  }

  function test_getExchangeRate() public view {
    uint256 rEthRate = uint256(
      IChainlinkAggregator(MiscArbitrum.rETH_ETH_AGGREGATOR).latestAnswer()
    );
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(MiscArbitrum.wstETH_stETH_AGGREGATOR).latestAnswer()
    );
    uint256 weEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeArbitrum.weETH_eETH_AGGREGATOR).latestAnswer()
    );
    uint256 ezEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeArbitrum.ezETH_ETH_AGGREGATOR).latestAnswer()
    );

    uint256 rsETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeArbitrum.rsETH_ETH_AGGREGATOR).latestAnswer()
    );

    console.log('Arbitrum');
    console.log('rEthRate', rEthRate);
    console.log('wstEthRate', wstEthRate);
    console.log('weEthRate', weEthRate);
    console.log('ezEthRate', ezEthRate);
    console.log('rsETHRate', rsETHRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesAvax is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('avalanche'), 70585400); // Oct-19-2025
  }

  function test_getExchangeRate() public view {
    uint256 sAvaxRate = ISAvax(AaveV3AvalancheAssets.sAVAX_UNDERLYING).getPooledAvaxByShares(
      10 ** 18
    );

    int256 wrsETHRate = IChainlinkAggregator(ChainlinkAvalanche.WRSETH_ETH_Exchange_Rate)
      .latestAnswer();

    console.log('Avalanche');
    // console.log('sAvaxRate', sAvaxRate);
    console.log('wrsETHRate', wrsETHRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRatesBase is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 39376200); // Dec-12-2025
  }

  function test_getExchangeRate() public view {
    uint256 cbEthRate = uint256(IChainlinkAggregator(MiscBase.cbETH_ETH_AGGREGATOR).latestAnswer());
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(MiscBase.wstETH_stETH_AGGREGATOR).latestAnswer()
    );
    uint256 weEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeBase.weETH_eETH_AGGREGATOR).latestAnswer()
    );
    uint256 ezEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeBase.ezETH_ETH_AGGREGATOR).latestAnswer()
    );

    uint256 rsETHRate = uint256(IRsETHL2(CapAdaptersCodeBase.rsETH_LRT_ORACLE).rate());

    uint256 rsETHCLRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeBase.rsETH_ETH_AGGREGATOR).latestAnswer()
    );

    uint256 syrupUSDCCLRate = uint256(
      IChainlinkAggregator(ChainlinkBase.syrupUSDC_USDC_Exchange_Rate).latestAnswer()
    );

    console.log('Base');
    console.log('cbEthRate', cbEthRate);
    console.log('wstEthRate', wstEthRate);
    console.log('weEthRate', weEthRate);
    console.log('ezEthRate', ezEthRate);
    console.log('rsETHRate', rsETHRate);
    console.log('rsETHCLRate', rsETHCLRate);
    console.log('syrupUSDCCLRate', syrupUSDCCLRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRatesGnosis is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('gnosis'), 39890000); // May-4-2025
  }

  function test_getExchangeRate() public view {
    uint256 sDaiRate = IERC4626(AaveV3GnosisAssets.sDAI_UNDERLYING).convertToAssets(10 ** 18);
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(MiscGnosis.wstETH_stETH_AGGREGATOR).latestAnswer()
    );

    console.log('Gnosis');
    console.log('sDaiRate', sDaiRate);
    console.log('wstEthRate', wstEthRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRatesOptimism is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 116196954); // 15th of February
  }

  function test_getExchangeRate() public view {
    uint256 rEthRate = uint256(
      IChainlinkAggregator(MiscOptimism.rETH_ETH_AGGREGATOR).latestAnswer()
    );
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(MiscOptimism.wstETH_stETH_AGGREGATOR).latestAnswer()
    );

    console.log('Optimism');
    console.log('rEthRate', rEthRate);
    console.log('wstEthRate', wstEthRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRates7Polygon is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 53527296); // 15th of February days ago
  }

  function test_getExchangeRate() public view {
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(MiscPolygon.wstETH_stETH_AGGREGATOR).latestAnswer()
    );

    console.log('Polygon 7');
    console.log('wstEthRate', wstEthRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRates14Polygon is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), 53252303); // 8th of February days ago
  }

  function test_getExchangeRate() public view {
    uint256 stMaticRate = IMaticRateProvider(MiscPolygon.stMATIC_RATE_PROVIDER).getRate();
    uint256 maticXRate = IMaticRateProvider(MiscPolygon.MaticX_RATE_PROVIDER).getRate();

    console.log('Polygon 14');
    console.log('stMaticRate', stMaticRate);
    console.log('maticXRate', maticXRate);

    console.log(block.timestamp);
  }
}

contract ExchangeRatesScroll is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('scroll'), 7740000); // July 24th
  }

  function test_getExchangeRate() public view {
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(0xE61Da4C909F7d86797a0D06Db63c34f76c9bCBDC).latestAnswer()
    );
    uint256 weEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeScroll.weETH_eETH_AGGREGATOR).latestAnswer()
    );

    console.log('Scroll');
    console.log('wstEthRate', wstEthRate);
    console.log('weEthRate', weEthRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesBNB is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('bnb'), 42938803); // Oct-08-2024
  }

  function test_getExchangeRate() public view {
    uint256 wstEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeBNB.wstETH_stETH_AGGREGATOR).latestAnswer()
    );

    uint256 bnbxRate = uint256(
      IBNBx(CapAdaptersCodeBNB.BNBx_STAKE_MANAGER_V2).convertBnbXToBnb(10 ** 18)
    );

    console.log('BNB');
    console.log('wstEthRate', wstEthRate);
    console.log('bnbxRate', bnbxRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesZKSync is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('zksync'), 57550360); // Mar-12-2025
  }

  function test_getExchangeRate() public view {
    uint256 weETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.weETH_eETH_AGGREGATOR).latestAnswer()
    );

    uint256 sUSDeRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.sUSDe_USDe_AGGREGATOR).latestAnswer()
    );

    uint256 rsETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeZkSync.rsETH_ETH_AGGREGATOR).latestAnswer()
    );

    console.log('ZkSync');
    console.log('weETHRate', weETHRate);
    console.log('sUSDeRate', sUSDeRate);
    console.log('rsETHRate', rsETHRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesLinea is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('linea'), 16741300); // Mar-09-2025
  }

  function test_getExchangeRate() public view {
    uint256 ezETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeLinea.ezETH_ETH_AGGREGATOR).latestAnswer()
    );

    uint256 weETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeLinea.weETH_eETH_AGGREGATOR).latestAnswer()
    );

    uint256 wstEthRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeLinea.wstETH_stETH_AGGREGATOR).latestAnswer()
    );

    uint256 wrsETHRate = uint256(
      IChainlinkAggregator(CapAdaptersCodeLinea.wrsETH_rsETH_AGGREGATOR).latestAnswer()
    );

    console.log('Linea');
    console.log('ezETHRate', ezETHRate);
    console.log('weETHRate', weETHRate);
    console.log('wstEthRate', wstEthRate);
    console.log('wrsETHRate', wrsETHRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesSonic is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('sonic'), 16058000); // Mar-26-2025
  }

  function test_getExchangeRate() public view {
    uint256 stSRate = IStS(CapAdaptersCodeSonic.StS).convertToAssets(1 ether);

    console.log('stSRate', stSRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesPlasma is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('plasma'), 3076200); // Oct-09-2025
  }

  function test_exchangeRate() public view {
    int256 syrupUSDTRate = IChainlinkAggregator(CapAdaptersCodePlasma.syrupUSDT_AGGREGATOR)
      .latestAnswer();

    console.log('syrupUSDTRate', syrupUSDTRate);
    console.log(block.timestamp);
  }
}

contract ExchangeRatesInk is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ink'), 29360402);
  }

  function test_exchangeRate() public view {
    int256 wrstETHRate = IChainlinkAggregator(CapAdaptersCodeInk.WrsETH_ETH_PRICE_FEED)
      .latestAnswer();
    int256 ezETHRate = IChainlinkAggregator(CapAdaptersCodeInk.EzETH_ETH_PRICE_FEED).latestAnswer();

    console.log('wrstETHRate', wrstETHRate);
    console.log('ezETHRate', ezETHRate);
    console.log(block.timestamp);
  }
}
