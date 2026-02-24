// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';

import {IACLManager, BasicIACLManager} from 'aave-address-book/AaveV3.sol';
import {GovV3Helpers} from 'aave-helpers/GovV3Helpers.sol';
import {IPriceCapAdapterStable, ICLSynchronicityPriceAdapter} from '../src/interfaces/IPriceCapAdapterStable.sol';
import {BlockUtils} from './utils/BlockUtils.sol';
import {PriceCapAdapterStable} from '../src/contracts/PriceCapAdapterStable.sol';
import {IEURPriceCapAdapterStable} from '../src/interfaces/IEURPriceCapAdapterStable.sol';

abstract contract BaseStableTest is Test {
  uint256 public constant RETROSPECTIVE_STEP = 3;
  uint256 public immutable RETROSPECTIVE_DAYS;

  struct ForkParams {
    string network;
    uint256 blockNumber;
  }

  ForkParams public forkParams;
  bytes public deploymentCode;
  bytes public adapterParams;

  constructor(
    bytes memory _deploymentCodeOrParams,
    uint8 _retrospectiveDays,
    ForkParams memory _forkParams
  ) {
    forkParams = _forkParams;
    RETROSPECTIVE_DAYS = _retrospectiveDays;
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
    IPriceCapAdapterStable adapter = _createAdapter();

    int256 price = adapter.latestAnswer();
    int256 referencePrice = adapter.ASSET_TO_USD_AGGREGATOR().latestAnswer();

    assertFalse(adapter.isCapped());
    assertEq(price, referencePrice);
  }

  /// @dev check if cap decimals was set correctly
  function test_configuration() public {
    IPriceCapAdapterStable adapter = _createAdapter();

    uint256 priceCap;
    try adapter.getPriceCap() returns (int256 _priceCap) {
      // forge-lint: disable-next-line(unsafe-typecast)
      priceCap = uint256(_priceCap);
    } catch {
      priceCap = uint256(IEURPriceCapAdapterStable(address(adapter)).getPriceCapRatio());
    }

    uint256 decimals = 10 ** adapter.decimals();

    assertEq(priceCap / (decimals * 10), 0);
  }

  function test_latestAnswerRetrospective() public virtual {
    uint256 finishBlock = forkParams.blockNumber;

    // get start block
    uint256 currentBlock = BlockUtils.getStartBlock(
      finishBlock,
      RETROSPECTIVE_DAYS,
      forkParams.network
    );
    vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

    IPriceCapAdapterStable adapter = _createAdapter();

    // persist adapter
    vm.makePersistent(address(adapter));

    // get step
    uint256 step = BlockUtils.getStep(RETROSPECTIVE_STEP, forkParams.network);

    while (currentBlock <= finishBlock) {
      vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

      int256 price = adapter.latestAnswer();
      int256 referencePrice = adapter.ASSET_TO_USD_AGGREGATOR().latestAnswer();

      assertFalse(adapter.isCapped());
      assertEq(price, referencePrice);

      currentBlock += step;
    }

    vm.revokePersistent(address(adapter));
    vm.createSelectFork(vm.rpcUrl(forkParams.network), finishBlock);
  }

  function _createAdapter() internal returns (IPriceCapAdapterStable) {
    if (keccak256(bytes(forkParams.network)) == keccak256(bytes('zksync'))) {
      return
        new PriceCapAdapterStable{salt: 'test'}(
          abi.decode(adapterParams, (IPriceCapAdapterStable.CapAdapterStableParams))
        );
    }
    return IPriceCapAdapterStable(GovV3Helpers.deployDeterministic(deploymentCode));
  }
}
