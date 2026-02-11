// SPDX-License-Identifier:  BUSL-1.1
pragma solidity ^0.8.19;

import {Test} from 'forge-std/Test.sol';

// We will check CLRatePriceCapAdapter instead of base, cause it's not abstract and often used
import {CLRatePriceCapAdapter, IPriceCapAdapter, IACLManager, IChainlinkAggregator} from '../../src/contracts/CLRatePriceCapAdapter.sol';

import {ChainlinkAggregatorMock} from './mocks/ChainlinkAggregatorMock.sol';
import {RatioProviderMock} from './mocks/RatioProviderMock.sol';
import {ACLManagerMock} from './mocks/ACLManagerMock.sol';

contract PriceCapAdapterBaseTest is Test {
  ChainlinkAggregatorMock public assetToUsdAggregator;
  RatioProviderMock public ratioProviderMock;
  ACLManagerMock public aclManager;

  CLRatePriceCapAdapter public capAdapter;

  address public riskAdmin = address(0xDead);
  address public poolAdmin = address(0xBeef);

  function setUp() public {
    skip(365 days + 1);

    assetToUsdAggregator = new ChainlinkAggregatorMock(1e8);
    ratioProviderMock = new RatioProviderMock(1e8, 5_00, 8);
    aclManager = new ACLManagerMock(poolAdmin, riskAdmin);

    IPriceCapAdapter.CapAdapterParams memory params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    capAdapter = new CLRatePriceCapAdapter(params);
  }

  function test_setup() public view {
    assertEq(address(capAdapter.BASE_TO_USD_AGGREGATOR()), address(assetToUsdAggregator));
    assertEq(address(capAdapter.ACL_MANAGER()), address(aclManager));
    assertEq(capAdapter.RATIO_PROVIDER(), address(ratioProviderMock));
    assertEq(capAdapter.DECIMALS(), 8);
    assertEq(capAdapter.RATIO_DECIMALS(), 8);
    assertEq(capAdapter.MINIMUM_SNAPSHOT_DELAY(), 0);
    assertEq(capAdapter.description(), 'description');

    assertEq(capAdapter.getSnapshotRatio(), 1e8);
    assertEq(capAdapter.getMaxRatioGrowthPerSecond(), 0);
    assertEq(capAdapter.getMaxRatioGrowthPerSecondScaled(), 317097);
    assertEq(capAdapter.getMaxYearlyGrowthRatePercent(), 10_00);
    assertEq(capAdapter.getSnapshotTimestamp(), block.timestamp);
    assertEq(capAdapter.latestAnswer(), 1e8);
    assertEq(capAdapter.getRatio(), 1e8);
    assertEq(capAdapter.isCapped(), false);
  }

  function test_invalidSetup() public {
    IPriceCapAdapter.CapAdapterParams memory params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(0)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapter.ACLManagerIsZeroAddress.selector));
    CLRatePriceCapAdapter newCapAdapter = new CLRatePriceCapAdapter(params);

    RatioProviderMock newRatioProviderMock = new RatioProviderMock(1e8, 5_00, 7);

    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(newRatioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapter.WrongRatioDecimals.selector));
    newCapAdapter = new CLRatePriceCapAdapter(params);

    newRatioProviderMock = new RatioProviderMock(1e8, 5_00, 25);

    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(newRatioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapter.WrongRatioDecimals.selector));
    newCapAdapter = new CLRatePriceCapAdapter(params);

    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(0),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert();
    newCapAdapter = new CLRatePriceCapAdapter(params);

    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 0,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapter.SnapshotRatioIsZero.selector));
    newCapAdapter = new CLRatePriceCapAdapter(params);

    skip(60);
    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 5,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(
      abi.encodeWithSelector(
        IPriceCapAdapter.InvalidRatioTimestamp.selector,
        uint48(block.timestamp)
      )
    );
    newCapAdapter = new CLRatePriceCapAdapter(params);

    uint256 timestamp = block.timestamp;

    skip(366 days);

    params = IPriceCapAdapter.CapAdapterParams({
      aclManager: IACLManager(address(aclManager)),
      baseAggregatorAddress: address(assetToUsdAggregator),
      ratioProviderAddress: address(ratioProviderMock),
      pairDescription: 'description',
      minimumSnapshotDelay: 0,
      priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: 1e8,
        // forge-lint: disable-next-line(unsafe-typecast)
        snapshotTimestamp: uint48(timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      })
    });

    vm.expectRevert(
      // forge-lint: disable-next-line(unsafe-typecast)
      abi.encodeWithSelector(IPriceCapAdapter.InvalidRatioTimestamp.selector, uint48(timestamp))
    );
    newCapAdapter = new CLRatePriceCapAdapter(params);
  }

  function test_fuzzRates(uint16 rate, uint8 decimals) public {
    rate = uint16(bound(rate, 1, 10_000));
    decimals = uint8(bound(decimals, 8, 24));

    skip(1);

    IPriceCapAdapter.PriceCapUpdateParams memory priceCapParams = IPriceCapAdapter
      .PriceCapUpdateParams({
        snapshotRatio: uint104(10 ** decimals),
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: rate
      });

    vm.startPrank(riskAdmin);
    capAdapter.setCapParameters(priceCapParams);

    assertGt(rate, 0);
    // could be zero
    assertGe(capAdapter.getMaxRatioGrowthPerSecond(), 0);
    // should be always greater than zero
    assertGt(capAdapter.getMaxRatioGrowthPerSecondScaled(), 0);
  }

  function test_latestAnswerAndIsCapped() public {
    // Cap restrict only price growth, it can decrease up to negative value
    assetToUsdAggregator.setLatestAnswer(-1);

    assertEq(capAdapter.latestAnswer(), 0);
    assertEq(capAdapter.isCapped(), false);

    assetToUsdAggregator.setLatestAnswer(1e8);

    assertEq(capAdapter.latestAnswer(), 1e8);

    // If ratio for some reason become negative, we still should return 0
    ratioProviderMock.set(-1, 10_00);

    assertEq(capAdapter.latestAnswer(), 0);
    assertEq(capAdapter.isCapped(), false);
  }

  function test_cap(uint16 rate, uint16 increasedRate) public {
    rate = uint16(bound(rate, 1, 50_00));
    increasedRate = uint16(bound(increasedRate, rate + 1, 10_000));

    skip(1);

    vm.startPrank(riskAdmin);
    IPriceCapAdapter.PriceCapUpdateParams memory priceCapParams = IPriceCapAdapter
      .PriceCapUpdateParams({
        snapshotRatio: uint104(1e8),
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: rate
      });
    capAdapter.setCapParameters(priceCapParams);

    // forge-lint: disable-next-line(unsafe-typecast)
    ratioProviderMock.set(1e8, int16(int256(uint256(increasedRate))));

    skip(180 days);

    assertEq(capAdapter.isCapped(), true);
    assertGe(ratioProviderMock.latestAnswer(), capAdapter.latestAnswer());
  }

  function test_manager() public {
    skip(1);

    vm.startPrank(poolAdmin);
    IPriceCapAdapter.PriceCapUpdateParams memory priceCapParams = IPriceCapAdapter
      .PriceCapUpdateParams({
        snapshotRatio: uint104(1e10),
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      });

    capAdapter.setCapParameters(priceCapParams);
    assertEq(capAdapter.getSnapshotRatio(), 1e10);

    vm.stopPrank();

    skip(1);

    vm.startPrank(riskAdmin);

    priceCapParams = IPriceCapAdapter.PriceCapUpdateParams({
      snapshotRatio: uint104(1e8),
      snapshotTimestamp: uint48(block.timestamp),
      maxYearlyRatioGrowthPercent: 10_00
    });
    capAdapter.setCapParameters(priceCapParams);
    assertEq(capAdapter.getSnapshotRatio(), 1e8);
  }

  function test_access(address someone) public {
    vm.assume(someone != riskAdmin && someone != poolAdmin);

    skip(1);

    IPriceCapAdapter.PriceCapUpdateParams memory priceCapParams = IPriceCapAdapter
      .PriceCapUpdateParams({
        snapshotRatio: uint104(1e8),
        snapshotTimestamp: uint48(block.timestamp),
        maxYearlyRatioGrowthPercent: 10_00
      });

    vm.expectRevert(abi.encodeWithSelector(IPriceCapAdapter.CallerIsNotRiskOrPoolAdmin.selector));
    capAdapter.setCapParameters(priceCapParams);
  }
}
