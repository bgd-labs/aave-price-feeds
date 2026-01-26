// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';
import {BaseAggregatorsBase} from '../src/lib/BaseAggregatorsBase.sol';
import {ChainlinkEthereum} from 'aave-address-book/ChainlinkEthereum.sol';
import {ChainlinkArbitrum} from 'aave-address-book/ChainlinkArbitrum.sol';
import {ChainlinkOptimism} from 'aave-address-book/ChainlinkOptimism.sol';
import {ChainlinkBase} from 'aave-address-book/ChainlinkBase.sol';

contract CLSynchronicityPriceAdapterPegToBaseTest is Test {
  uint256 public constant START_BLOCK = 15588955;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), START_BLOCK);
  }

  function testLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkEthereum.ETH__USD,
      ChainlinkEthereum.STETH__ETH,
      8,
      'stETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      129500000000, // value calculated manually for selected block
      100000000
    );
  }

  function testLatestAnswerWbtc() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkEthereum.BTC__USD,
      ChainlinkEthereum.WBTC__BTC,
      8,
      'wBTC/BTC/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      1923700000000, // value calculated manually for selected block
      10 ** 8
    );
  }

  function testLatestAnswercbETH() public {
    // the feed is not availble at START_BLOCK yet
    uint256 START_BLOCK_CB_ETH = 16477236;
    vm.rollFork(START_BLOCK_CB_ETH);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkEthereum.ETH__USD,
      ChainlinkEthereum.CBETH__ETH,
      8,
      'cbETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      162417252778, // value calculated manually for selected block (1003504805547725400 & 161850000000)
      10 ** 8
    );
  }

  function testLatestAnswerLDO() public {
    // the feed is not availble at START_BLOCK yet
    uint256 START_BLOCK_LDO_ETH = 16991307;
    vm.rollFork(START_BLOCK_LDO_ETH);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkEthereum.ETH__USD,
      ChainlinkEthereum.LDO__ETH,
      8,
      'LDO/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      252715331, // value calculated manually for selected block (1003504805547725400 & 161850000000)
      10 ** 8
    );
  }

  function testLatestAnswerWbtcRelativelyBtcFeed() public {
    IChainlinkAggregator aggregator = IChainlinkAggregator(ChainlinkEthereum.BTC__USD);

    for (uint256 i; i < 10; i++) {
      CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
        ChainlinkEthereum.BTC__USD,
        ChainlinkEthereum.WBTC__BTC,
        8,
        'wBTC/BTC/USD'
      );

      int256 price = adapter.latestAnswer();
      int256 btcPrice = aggregator.latestAnswer();

      assertApproxEqRel(price, btcPrice, 0.0003e18); // 0.03%

      vm.rollFork(START_BLOCK + 500 * (i + 1));
    }
  }

  function testPegToBaseOracleReturnsNegative() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, -1, 4);
    _setMockPrice(mockAggregator2, 10000, 4);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      mockAggregator1,
      mockAggregator2,
      4,
      'MOCK'
    );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function testAssetToPegOracleReturnsZero() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, 10000, 4);
    _setMockPrice(mockAggregator2, 0, 4);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      mockAggregator1,
      mockAggregator2,
      4,
      'MOCK'
    );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function _setMockPrice(address mockAggregator, int256 mockPrice, uint256 decimals) internal {
    bytes memory latestAnswerCall = abi.encodeWithSignature('latestAnswer()');
    bytes memory decimalsCall = abi.encodeWithSignature('decimals()');

    vm.mockCall(mockAggregator, latestAnswerCall, abi.encode(mockPrice));
    vm.mockCall(mockAggregator, decimalsCall, abi.encode(decimals));
  }
}

contract CLSynchronicityPriceAdapterPegToBaseTestPolygon is Test {
  uint256 public constant START_BLOCK = 41497996;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('polygon'), START_BLOCK);
  }

  function testLatestAnswerWstETHUSD() public {
    address DEPLOYED_CONTRACT = 0xA2508729b1282Cc70dd33Ed311d4A9A37383035b;

    CLSynchronicityPriceAdapterPegToBase adapter = CLSynchronicityPriceAdapterPegToBase(
      DEPLOYED_CONTRACT
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(uint256(price), 224312645700, 10 ** 8);
  }
}

contract CLrETHSynchronicityPriceAdapterTestArbitrum is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('arbitrum'), 99418608);
  }

  function testLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkArbitrum.ETH__USD,
      ChainlinkArbitrum.rETH_ETH_Exchange_Rate,
      8,
      'rETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      198221827481, // value calculated manually for selected block, there is a diff with DEXes at the moment
      10000
    );
  }
}

contract CLrETHSynchronicityPriceAdapterTestOptimism is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('optimism'), 106721725);
  }

  function testLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkOptimism.ETH__USD,
      ChainlinkOptimism.rETH_ETH_Exchange_Rate,
      8,
      'rETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      202660356782, // value calculated manually for selected block, there is a diff with DEXes at the moment
      10000
    );
  }
}

contract CLrETHSynchronicityPriceAdapterTestBase is Test {
  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('base'), 2187610);
  }

  function testLatestAnswerWstEth() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkBase.ETH__USD,
      ChainlinkBase.wstETH_stETH_Exchange_Rate,
      8,
      'wstETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(uint256(price), 208883070000, 10000);
  }

  function testLatestAnswerCbEth() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
      ChainlinkBase.ETH__USD,
      ChainlinkBase.CBETH__ETH,
      8,
      'cbETH/ETH/USD'
    );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(uint256(price), 192079109243, 10000);
  }
}
