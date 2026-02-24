// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterBaseToPeg} from '../src/contracts/CLSynchronicityPriceAdapterBaseToPeg.sol';
import {ICLSynchronicityPriceAdapter} from '../src/interfaces/ICLSynchronicityPriceAdapter.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';

contract StablecoinPriceAdapterFormulaTest is Test {
  IChainlinkAggregator public constant ETH_USD_AGGREGATOR =
    IChainlinkAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), 15588955);
  }

  function testFormula() public {
    uint256 TESTS_NUM = 10;

    int256 ethPrice = ETH_USD_AGGREGATOR.latestAnswer();
    uint8 ethAggregatorDecimals = ETH_USD_AGGREGATOR.decimals();

    for (uint256 i = 1; i <= TESTS_NUM; i++) {
      address mockAggregator = address(0);
      // forge-lint: disable-next-line(unsafe-typecast)
      int256 mockPrice = ethPrice / int256(i);
      _setMockPrice(mockAggregator, mockPrice, 8);

      CLSynchronicityPriceAdapterBaseToPeg adapter = new CLSynchronicityPriceAdapterBaseToPeg(
        address(ETH_USD_AGGREGATOR),
        mockAggregator,
        18,
        'MOCK'
      );

      int256 price = adapter.latestAnswer();
      // forge-lint: disable-next-line(unsafe-typecast)
      int256 expectedPriceInEth = int256(1 ether / i);

      int256 maxDiff = int256(10 ** (ethAggregatorDecimals));
      // forge-lint: disable-next-line(unsafe-typecast)
      assertApproxEqAbs(uint256(price), uint256(expectedPriceInEth), uint256(maxDiff));
    }
  }

  function testBaseToPegOracleReturnsZero() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, 0, 4);
    _setMockPrice(mockAggregator2, 10000, 4);

    CLSynchronicityPriceAdapterBaseToPeg adapter = new CLSynchronicityPriceAdapterBaseToPeg(
      mockAggregator1,
      mockAggregator2,
      4,
      'MOCK'
    );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function testAssetToPegOracleReturnsNegative() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, 10000, 4);
    _setMockPrice(mockAggregator2, -1, 4);

    CLSynchronicityPriceAdapterBaseToPeg adapter = new CLSynchronicityPriceAdapterBaseToPeg(
      mockAggregator1,
      mockAggregator2,
      4,
      'MOCK'
    );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function testConstructorIsRevertedWhenDecimalsIsDifferent() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, 1000, 3);
    _setMockPrice(mockAggregator2, 10000, 4);

    vm.expectRevert(ICLSynchronicityPriceAdapter.DecimalsNotEqual.selector);

    new CLSynchronicityPriceAdapterBaseToPeg(mockAggregator1, mockAggregator2, 4, 'MOCK');
  }

  function _setMockPrice(address mockAggregator, int256 mockPrice, uint256 decimals) internal {
    bytes memory latestAnswerCall = abi.encodeWithSignature('latestAnswer()');
    bytes memory decimalsCall = abi.encodeWithSignature('decimals()');

    vm.mockCall(mockAggregator, latestAnswerCall, abi.encode(mockPrice));
    vm.mockCall(mockAggregator, decimalsCall, abi.encode(decimals));
  }
}
