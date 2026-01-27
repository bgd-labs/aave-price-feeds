// SPDX-License-Identifier:  BUSL-1.1
pragma solidity ^0.8.19;

import {Test} from 'forge-std/Test.sol';

import {PriceCapAdapterStable, IPriceCapAdapterStable, IACLManager, IChainlinkAggregator} from '../../src/contracts/PriceCapAdapterStable.sol';

import {ChainlinkAggregatorMock} from './mocks/ChainlinkAggregatorMock.sol';
import {ACLManagerMock} from './mocks/ACLManagerMock.sol';

contract PriceCapAdapterStableTest is Test {
  ChainlinkAggregatorMock public chainlinkAggregator;
  IACLManager public manager;

  PriceCapAdapterStable public stableCapo;

  address public poolAdmin = vm.addr(0x01);
  address public riskAdmin = vm.addr(0x02);

  function setUp() public {
    chainlinkAggregator = new ChainlinkAggregatorMock(1e8);
    manager = IACLManager(address(new ACLManagerMock(poolAdmin, riskAdmin)));

    IPriceCapAdapterStable.CapAdapterStableParams memory params = IPriceCapAdapterStable
      .CapAdapterStableParams({
        assetToUsdAggregator: IChainlinkAggregator(chainlinkAggregator),
        aclManager: IACLManager(manager),
        adapterDescription: 'description',
        priceCap: 1.04e8
      });
    stableCapo = new PriceCapAdapterStable(params);
  }

  function test_setup() public {
    IPriceCapAdapterStable.CapAdapterStableParams memory params = IPriceCapAdapterStable
      .CapAdapterStableParams({
        assetToUsdAggregator: IChainlinkAggregator(address(0)),
        aclManager: IACLManager(manager),
        adapterDescription: 'description',
        priceCap: 1.04e8
      });

    vm.expectRevert();
    PriceCapAdapterStable newStableCapo = new PriceCapAdapterStable(params);

    params = IPriceCapAdapterStable.CapAdapterStableParams({
      assetToUsdAggregator: IChainlinkAggregator(chainlinkAggregator),
      aclManager: IACLManager(address(0)),
      adapterDescription: 'description',
      priceCap: 1.04e8
    });

    vm.expectRevert(
      abi.encodeWithSelector(IPriceCapAdapterStable.ACLManagerIsZeroAddress.selector)
    );
    newStableCapo = new PriceCapAdapterStable(params);

    params = IPriceCapAdapterStable.CapAdapterStableParams({
      assetToUsdAggregator: IChainlinkAggregator(chainlinkAggregator),
      aclManager: IACLManager(manager),
      adapterDescription: 'description',
      priceCap: -1
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapterStable.InvalidNewPriceCap.selector));
    newStableCapo = new PriceCapAdapterStable(params);

    params = IPriceCapAdapterStable.CapAdapterStableParams({
      assetToUsdAggregator: IChainlinkAggregator(chainlinkAggregator),
      aclManager: IACLManager(manager),
      adapterDescription: 'description',
      priceCap: type(int256).max
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapterStable.InvalidNewPriceCap.selector));
    newStableCapo = new PriceCapAdapterStable(params);
  }

  function test_correctSetup() public view {
    vm.assertEq(address(stableCapo.ASSET_TO_USD_AGGREGATOR()), address(chainlinkAggregator));
    vm.assertEq(address(stableCapo.ACL_MANAGER()), address(manager));
    vm.assertEq(stableCapo.description(), 'description');
    vm.assertEq(stableCapo.decimals(), 8);

    uint256 timestamp = vm.getBlockTimestamp();
    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = stableCapo.latestRoundData();

    vm.assertEq(stableCapo.latestAnswer(), 1e8);
    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);
    vm.assertEq(stableCapo.isCapped(), false);
    vm.assertEq(roundId, uint80(timestamp));
    vm.assertEq(answer, 1e8);
    vm.assertEq(startedAt, timestamp);
    vm.assertEq(updatedAt, timestamp);
    vm.assertEq(answeredInRound, uint80(timestamp));
  }

  function test_capo() public {
    vm.assertEq(stableCapo.latestAnswer(), 1e8);
    uint256 timestamp = vm.getBlockTimestamp();
    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = stableCapo.latestRoundData();
    vm.assertEq(roundId, uint80(timestamp));
    vm.assertEq(answer, 1e8);
    vm.assertEq(startedAt, timestamp);
    vm.assertEq(updatedAt, timestamp);
    vm.assertEq(answeredInRound, uint80(timestamp));

    // Cap restricts only price growth
    chainlinkAggregator.setLatestAnswer(1.05e8);
    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);
    vm.assertEq(stableCapo.latestAnswer(), 1.04e8);
    vm.assertEq(stableCapo.isCapped(), true);
    timestamp = vm.getBlockTimestamp();
    (roundId, answer, startedAt, updatedAt, answeredInRound) = stableCapo.latestRoundData();
    vm.assertEq(roundId, uint80(timestamp));
    vm.assertEq(answer, 1.04e8);
    vm.assertEq(startedAt, timestamp);
    vm.assertEq(updatedAt, timestamp);
    vm.assertEq(answeredInRound, uint80(timestamp));

    chainlinkAggregator.setLatestAnswer(0);
    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);
    vm.assertEq(stableCapo.latestAnswer(), 0);
    vm.assertEq(stableCapo.isCapped(), false);
    timestamp = vm.getBlockTimestamp();
    (roundId, answer, startedAt, updatedAt, answeredInRound) = stableCapo.latestRoundData();
    vm.assertEq(roundId, uint80(timestamp));
    vm.assertEq(answer, 0);
    vm.assertEq(startedAt, timestamp);
    vm.assertEq(updatedAt, timestamp);
    vm.assertEq(answeredInRound, uint80(timestamp));

    // In case price somehow become negative
    chainlinkAggregator.setLatestAnswer(-1);
    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);
    vm.assertEq(stableCapo.latestAnswer(), 0);
    vm.assertEq(stableCapo.isCapped(), false);
    timestamp = vm.getBlockTimestamp();
    (roundId, answer, startedAt, updatedAt, answeredInRound) = stableCapo.latestRoundData();
    vm.assertEq(roundId, uint80(timestamp));
    vm.assertEq(answer, 0);
    vm.assertEq(startedAt, timestamp);
    vm.assertEq(updatedAt, timestamp);
    vm.assertEq(answeredInRound, uint80(timestamp));
  }

  function test_manager() public {
    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);

    vm.startPrank(poolAdmin);

    stableCapo.setPriceCap(1.06e8);

    vm.assertEq(stableCapo.getPriceCap(), 1.06e8);

    vm.stopPrank();
    vm.startPrank(riskAdmin);

    stableCapo.setPriceCap(1.04e8);

    vm.assertEq(stableCapo.getPriceCap(), 1.04e8);
  }

  function test_access(address someone) public {
    vm.assume(someone != riskAdmin && someone != poolAdmin);

    vm.expectRevert(
      abi.encodeWithSelector(IPriceCapAdapterStable.CallerIsNotRiskOrPoolAdmin.selector)
    );
    stableCapo.setPriceCap(1.06e8);
  }
}
