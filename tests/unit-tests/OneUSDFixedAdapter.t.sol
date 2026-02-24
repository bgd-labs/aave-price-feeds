// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// forge test --match-contract OneUSDFixedAdapterTest -vvv
// forge coverage --match-contract OneUSDFixedAdapterTest --report summary

import {Test} from 'forge-std/Test.sol';
import {OneUSDFixedAdapter} from '../../src/contracts/misc-adapters/OneUSDFixedAdapter.sol';

contract OneUSDFixedAdapterTest is Test {
  OneUSDFixedAdapter adapter;

  function setUp() public {
    adapter = new OneUSDFixedAdapter();
  }

  function test_latestAnswer() external view {
    assertEq(adapter.latestAnswer(), 1e8);
  }

  function test_decimals() external view {
    assertEq(adapter.decimals(), 8);
    assertEq(adapter.DECIMALS(), 8);
  }

  function test_description() external view {
    assertEq(adapter.description(), 'ONE USD');
  }

  function test_ONE_USD() external view {
    assertEq(adapter.ONE_USD(), 1e8);
  }

  function test_latestRoundData() external view {
    (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ) = adapter.latestRoundData();

    assertEq(roundId, 0);
    assertEq(answer, 1e8);
    assertEq(startedAt, block.timestamp);
    assertEq(updatedAt, block.timestamp);
    assertEq(answeredInRound, 0);
  }
}
