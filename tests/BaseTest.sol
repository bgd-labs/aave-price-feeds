// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {IACLManager, BasicIACLManager} from 'aave-address-book/AaveV3.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {IPriceCapAdapter, ICLSynchronicityPriceAdapter} from '../src/interfaces/IPriceCapAdapter.sol';
import {BlockUtils} from './utils/BlockUtils.sol';

abstract contract BaseTest is Test {
  uint256 public constant SECONDS_PER_DAY = 86400;
  uint256 public constant SECONDS_PER_YEAR = 365 days;

  uint256 public constant RETROSPECTIVE_STEP = 1;
  uint256 public immutable RETROSPECTIVE_DAYS;

  struct ForkParams {
    string network;
    uint256 blockNumber;
  }

  struct PriceParams {
    int256 sourcePrice;
    int256 referencePrice;
    uint256 blockNumber;
    uint256 timestamp;
    int256 ratio;
    int256 dayToDayGrowth;
    int256 smoothedGrowth;
  }

  ForkParams public forkParams;
  bytes public deploymentCode;
  bytes public adapterParams;
  string public reportName;
  PriceParams[] prices;

  constructor(
    bytes memory _deploymentCodeOrParams,
    uint8 _retrospectiveDays,
    ForkParams memory _forkParams,
    string memory _reportName
  ) {
    forkParams = _forkParams;
    RETROSPECTIVE_DAYS = _retrospectiveDays;
    reportName = _reportName;
    if (keccak256(bytes(_forkParams.network)) == keccak256(bytes('zksync'))) {
      adapterParams = _deploymentCodeOrParams;
    } else {
      deploymentCode = _deploymentCodeOrParams;
    }
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(forkParams.network), forkParams.blockNumber);
  }

  function test_latestAnswer() public virtual {
    IPriceCapAdapter adapter = _createAdapter();

    int256 price = adapter.latestAnswer();
    int256 priceOfReferenceAdapter = adapter.BASE_TO_USD_AGGREGATOR().latestAnswer();

    assertFalse(adapter.isCapped());
    assertGe(
      price,
      priceOfReferenceAdapter,
      'lst price is not greater than the reference adapter price'
    );
  }

  function test_latestAnswerRetrospective() public virtual {
    uint256 finishBlock = forkParams.blockNumber;

    // get adapter parameters
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams = _getCapAdapterParams();

    // get start block
    uint256 currentBlock = BlockUtils.getStartBlock(
      finishBlock,
      RETROSPECTIVE_DAYS,
      forkParams.network
    );

    IPriceCapAdapter adapter = _createRetrospectiveAdapter(capAdapterParams, currentBlock);
    uint256 snapshotDelayDays = uint256(adapter.MINIMUM_SNAPSHOT_DELAY()) / SECONDS_PER_DAY;

    // persist adapter
    vm.makePersistent(address(adapter));

    // get step
    uint256 step = BlockUtils.getStep(RETROSPECTIVE_STEP, forkParams.network);
    uint256 i = 0;

    while (currentBlock <= finishBlock) {
      vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

      int256 price = adapter.latestAnswer();
      int256 priceOfReferenceAdapter = adapter.BASE_TO_USD_AGGREGATOR().latestAnswer();
      int256 ratio = adapter.getRatio();

      int256 dayToDayGrowthPercent = 0;

      if (i > 0) {
        dayToDayGrowthPercent = _calculateGrowthPercent(
          ratio,
          prices[i - 1].ratio,
          block.timestamp,
          prices[i - 1].timestamp
        );
      }

      int256 smoothedGrowth = 0;

      if (i >= snapshotDelayDays) {
        smoothedGrowth = _calculateGrowthPercent(
          ratio,
          prices[i - snapshotDelayDays].ratio,
          block.timestamp,
          prices[i - snapshotDelayDays].timestamp
        );
      }

      prices.push(
        PriceParams({
          sourcePrice: price,
          referencePrice: priceOfReferenceAdapter,
          blockNumber: currentBlock,
          timestamp: block.timestamp,
          ratio: ratio,
          dayToDayGrowth: dayToDayGrowthPercent,
          smoothedGrowth: smoothedGrowth
        })
      );

      assertFalse(adapter.isCapped());

      currentBlock += step;
      i++;
    }

    _generateReport(
      adapter.description(),
      ICLSynchronicityPriceAdapter(address(adapter.BASE_TO_USD_AGGREGATOR())).description(),
      adapter.decimals(),
      capAdapterParams.priceCapParams.maxYearlyRatioGrowthPercent,
      snapshotDelayDays
    );

    vm.revokePersistent(address(adapter));
    vm.createSelectFork(vm.rpcUrl(forkParams.network), finishBlock);
  }

  function test_cappedLatestAnswer() public virtual {
    // deploy adapter
    IPriceCapAdapter adapter = _createAdapter();

    uint256 growthPercent = adapter.getMaxYearlyGrowthRatePercent();
    if (growthPercent > 0 && uint256(adapter.getRatio()) > adapter.getSnapshotRatio()) {
      // set yearly growth to 0.1%
      _setCapParametersByAdmin(
        adapter,
        uint104(adapter.getSnapshotRatio()),
        uint48(adapter.getSnapshotTimestamp() + 1),
        uint16(10)
      );
    } else {
      // adapters without a growth rate we mock the exchange rate
      uint256 ratioCapped = (_getMaxRatio(adapter) + 1);
      _mockRatioProviderRate(ratioCapped);
    }

    // check is capped
    assertTrue(adapter.isCapped());
  }

  function test_configuration() public {
    IPriceCapAdapter adapter = _createAdapter();
    _validateDecimals(adapter);
    _validateGrowth(adapter);
  }

  function _getCapAdapterParams() internal returns (IPriceCapAdapter.CapAdapterParams memory) {
    if (keccak256(bytes(forkParams.network)) == keccak256(bytes('zksync'))) {
      return abi.decode(adapterParams, (IPriceCapAdapter.CapAdapterParams));
    }
    IPriceCapAdapter adapter = _createAdapter();
    return
      IPriceCapAdapter.CapAdapterParams({
        aclManager: adapter.ACL_MANAGER(),
        baseAggregatorAddress: address(adapter.BASE_TO_USD_AGGREGATOR()),
        ratioProviderAddress: adapter.RATIO_PROVIDER(),
        pairDescription: adapter.description(),
        minimumSnapshotDelay: adapter.MINIMUM_SNAPSHOT_DELAY(),
        priceCapParams: IPriceCapAdapter.PriceCapUpdateParams({
          snapshotRatio: uint104(adapter.getSnapshotRatio()),
          snapshotTimestamp: uint48(adapter.getSnapshotTimestamp()),
          maxYearlyRatioGrowthPercent: uint16(adapter.getMaxYearlyGrowthRatePercent())
        })
      });
  }

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal virtual returns (IPriceCapAdapter) {}

  function _createAdapter() internal returns (IPriceCapAdapter) {
    if (keccak256(bytes(forkParams.network)) == keccak256(bytes('zksync'))) {
      return _createAdapter(_getCapAdapterParams());
    }
    return IPriceCapAdapter(GovV3Helpers.deployDeterministic(deploymentCode));
  }

  function _createRetrospectiveAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams,
    uint256 currentBlock
  ) internal returns (IPriceCapAdapter) {
    // save temporary minimum snapshot delay
    uint48 minimumSnapshotDelay = capAdapterParams.minimumSnapshotDelay;

    // get parameters for the adapter, which will be created
    vm.createSelectFork(
      vm.rpcUrl(forkParams.network),
      currentBlock - _getSnapshotDelayInBlocks(capAdapterParams.minimumSnapshotDelay)
    );

    capAdapterParams.priceCapParams.snapshotTimestamp = uint48(block.timestamp);
    capAdapterParams.priceCapParams.snapshotRatio = 1;
    capAdapterParams.minimumSnapshotDelay = 0;

    IPriceCapAdapter adapterTogetratio = _createAdapter(capAdapterParams);
    uint104 currentRatio = uint104(uint256(adapterTogetratio.getRatio()));

    // select current block and create retrospective adapter
    vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

    assertGe(
      uint48(block.timestamp) - capAdapterParams.priceCapParams.snapshotTimestamp,
      minimumSnapshotDelay,
      'BlockUtils is underestimating the number of block per day for the network'
    );

    capAdapterParams.priceCapParams.snapshotRatio = currentRatio;
    capAdapterParams.minimumSnapshotDelay = minimumSnapshotDelay;
    IPriceCapAdapter adapter = _createAdapter(capAdapterParams);

    return adapter;
  }

  function _setCapParametersByAdmin(
    IPriceCapAdapter adapter,
    uint104 snapshotRatio,
    uint48 snapshotTimestamp,
    uint16 maxYearlyRatioGrowthPercent
  ) internal {
    vm.mockCall(
      address(adapter.ACL_MANAGER()),
      abi.encodeWithSelector(BasicIACLManager.isRiskAdmin.selector),
      abi.encode(true)
    );

    adapter.setCapParameters(
      IPriceCapAdapter.PriceCapUpdateParams({
        snapshotRatio: snapshotRatio,
        snapshotTimestamp: snapshotTimestamp,
        maxYearlyRatioGrowthPercent: maxYearlyRatioGrowthPercent
      })
    );
  }

  function _getSnapshotDelayInBlocks(uint48 minimumSnapshotDelay) internal view returns (uint256) {
    return
      (minimumSnapshotDelay * BlockUtils.getBlocksPerDayByNetwork(forkParams.network)) /
      SECONDS_PER_DAY;
  }

  function _calculateGrowthPercent(
    int256 ratio,
    int256 previousRatio,
    uint256 currentTimestamp,
    uint256 previousTimestamp
  ) private pure returns (int256) {
    return
      // forge-lint: disable-next-line(unsafe-typecast)
      (((ratio - previousRatio) * int256(SECONDS_PER_YEAR)) * 100_00) /
      // forge-lint: disable-next-line(unsafe-typecast)
      (previousRatio * int256(currentTimestamp - previousTimestamp));
  }

  function _getMaxRatio(IPriceCapAdapter adapter) private view returns (uint256) {
    uint256 snapshotRatio = adapter.getSnapshotRatio();
    uint256 snapshotTimestamp = adapter.getSnapshotTimestamp();
    uint256 maxGrowthPerSecondScaled = adapter.getMaxRatioGrowthPerSecondScaled();
    uint256 SCALING_FACTOR = adapter.SCALING_FACTOR();

    return
      uint256(
        snapshotRatio +
          (maxGrowthPerSecondScaled * (block.timestamp - snapshotTimestamp)) /
          SCALING_FACTOR
      );
  }

  function _mockRatioProviderRate(uint256 amount) internal virtual {}

  /// @dev verifies that if growth in a year is greater than zero, growth per second scaled must be greater than zero
  /// and growth in a year won't be more than 100%
  function _validateGrowth(IPriceCapAdapter adapter) private view {
    uint256 maxYearlyGrowthRatePercent = adapter.getMaxYearlyGrowthRatePercent();

    if (maxYearlyGrowthRatePercent > 0) {
      // @dev For small values of the initial `snapshotRatio` and `maxYearlyRatioGrowthPercent` it can take a zero value
      assertGe(adapter.getMaxRatioGrowthPerSecond(), 0);
      // @dev In these cases it is recommended to look at `getMaxRatioGrowthPerSecondScaled()`
      assertGt(adapter.getMaxRatioGrowthPerSecondScaled(), 0);
    }

    assertLe(adapter.getMaxYearlyGrowthRatePercent(), adapter.PERCENTAGE_FACTOR());
  }

  /// @dev verifies ratio(snapshot, current, max) are at the same decimal places
  function _validateDecimals(IPriceCapAdapter adapter) private view {
    uint256 currentRatio = uint256(adapter.getRatio());
    uint256 snapshotRatio = adapter.getSnapshotRatio();
    uint256 maxRatio = _getMaxRatio(adapter);
    uint256 ratioDecimals = 10 ** adapter.RATIO_DECIMALS();

    assertEq(currentRatio / (ratioDecimals * 10), 0);
    assertEq(snapshotRatio / (ratioDecimals * 10), 0);
    assertEq(maxRatio / (ratioDecimals * 10), 0);
  }

  function _generateReport(
    string memory sourceName,
    string memory referenceName,
    uint8 decimals,
    uint16 maxYearlyGrowthPercent,
    uint256 snapshotDelayDays
  ) internal {
    string memory path = _generateJsonReport(
      sourceName,
      referenceName,
      decimals,
      maxYearlyGrowthPercent,
      snapshotDelayDays
    );
    _generateMdReport(path);

    string[] memory inputs = new string[](2);
    inputs[0] = 'rm';
    inputs[1] = path;
    vm.ffi(inputs);
  }

  function _generateJsonReport(
    string memory sourceName,
    string memory referenceName,
    uint8 decimals,
    uint16 maxYearlyGrowthPercent,
    uint256 snapshotDelayDays
  ) internal returns (string memory) {
    string memory path = string(abi.encodePacked('./reports/out/', reportName, '.json'));
    vm.serializeString('root', 'source', sourceName);
    vm.serializeString('root', 'reference', referenceName);
    vm.serializeUint('root', 'decimals', decimals);
    vm.serializeUint('root', 'maxYearlyGrowthPercent', maxYearlyGrowthPercent);
    vm.serializeUint('root', 'minSnapshotDelay', snapshotDelayDays);
    string memory pricesKey = 'prices';
    string memory content = '{}';
    vm.serializeJson(pricesKey, '{}');

    for (uint256 i = 0; i < prices.length; i++) {
      string memory key = vm.toString(prices[i].blockNumber);
      vm.serializeJson(key, '{}');
      vm.serializeUint(key, 'timestamp', prices[i].timestamp);
      vm.serializeInt(key, 'sourcePrice', prices[i].sourcePrice);
      vm.serializeInt(key, 'referencePrice', prices[i].referencePrice);
      vm.serializeInt(key, 'dayToDayGrowth', prices[i].dayToDayGrowth);
      string memory object = vm.serializeInt(key, 'smoothedGrowth', prices[i].smoothedGrowth);
      content = vm.serializeString(pricesKey, key, object);
    }

    string memory output = vm.serializeString('root', pricesKey, content);
    vm.writeJson(output, path);

    return path;
  }

  function _generateMdReport(string memory sourcePath) internal {
    string memory outPath = string(abi.encodePacked('./reports/out/', reportName, '.md'));

    string[] memory inputs = new string[](6);
    inputs[0] = './node_modules/.bin/tsx';
    inputs[1] = './reports/capo-report.ts';
    inputs[2] = '-i';
    inputs[3] = sourcePath;
    inputs[4] = '-o';
    inputs[5] = outPath;
    vm.ffi(inputs);
  }
}
