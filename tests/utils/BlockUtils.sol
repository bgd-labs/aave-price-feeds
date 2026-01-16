pragma solidity ^0.8.18;

import 'forge-std/Test.sol';

library BlockUtils {
  function getStartBlock(
    uint256 finishBlock,
    uint256 retrospectiveDays,
    string memory network
  ) internal pure returns (uint256) {
    return finishBlock - retrospectiveDays * getBlocksPerDayByNetwork(network);
  }

  function getStep(uint256 stepDays, string memory network) internal pure returns (uint256) {
    return stepDays * getBlocksPerDayByNetwork(network);
  }

  function getBlocksPerDayByNetwork(string memory network) internal pure returns (uint256) {
    if (keccak256(bytes(network)) == keccak256(bytes('mainnet'))) {
      return 7300;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('arbitrum'))) {
      return 345000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('avalanche'))) {
      return 55000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('base'))) {
      return 44000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('bnb'))) {
      return 30000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('optimism'))) {
      return 44000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('polygon'))) {
      return 38000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('scroll'))) {
      return 28800;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('gnosis'))) {
      return 17000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('zksync'))) {
      return 60_000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('linea'))) {
      return 43_200;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('sonic'))) {
      return 230_000;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('plasma'))) {
      return 86_400;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('ink'))) {
      return 86_400;
    }

    if (keccak256(bytes(network)) == keccak256(bytes('mantle'))) {
      return 43_200;
    }

    return 7300;
  }
}
