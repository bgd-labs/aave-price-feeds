// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IChainlinkAggregator} from '../../src/interfaces/IChainlinkAggregator.sol';

import './BaseTest.sol';
import {CLRatePriceCapAdapter} from '../src/contracts/CLRatePriceCapAdapter.sol';

abstract contract CLAdapterBaseTest is BaseTest {
  constructor(
    bytes memory _deploymentCode,
    uint8 _retrospectiveDays,
    ForkParams memory _forkParams,
    string memory _reportName
  ) BaseTest(_deploymentCode, _retrospectiveDays, _forkParams, _reportName) {}

  function _createAdapter(
    IPriceCapAdapter.CapAdapterParams memory capAdapterParams
  ) internal override returns (IPriceCapAdapter) {
    return new CLRatePriceCapAdapter(capAdapterParams);
  }
}
