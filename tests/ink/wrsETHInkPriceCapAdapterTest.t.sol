// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {CLAdapterBaseTest} from '../CLAdapterBaseTest.sol';
import {CapAdaptersCodeInk} from '../../scripts/DeployInk.s.sol';

contract wrsETHInkPriceCapAdapterTest is CLAdapterBaseTest {
  constructor()
    CLAdapterBaseTest(
      CapAdaptersCodeInk.wrsETHAdapterCode(),
      14,
      ForkParams({network: 'ink', blockNumber: 31174803}),
      'wrsETH_Ink'
    )
  {}
}
