// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBasicFeed} from './IBasicFeed.sol';

interface IExtendedFeed is IBasicFeed {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
