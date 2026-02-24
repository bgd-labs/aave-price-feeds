// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// forge test --match-contract DiscountedMKRSKYAdapterForkTest -vvv

import {Test} from 'forge-std/Test.sol';
import {AaveV3Ethereum} from 'aave-address-book/AaveV3Ethereum.sol';
import {DiscountedMKRSKYAdapter} from '../../src/contracts/misc-adapters/DiscountedMKRSKYAdapter.sol';
import {IDiscountedMKRSKYAdapter} from '../../src/interfaces/IDiscountedMKRSKYAdapter.sol';
import {IChainlinkAggregator} from '../../src/interfaces/IChainlinkAggregator.sol';
import {BlockUtils} from '../utils/BlockUtils.sol';

contract DiscountedMKRSKYAdapterForkTest is Test {
  uint256 public constant RETROSPECTIVE_STEP = 1; // days
  uint256 public constant RETROSPECTIVE_DAYS = 60;

  // Mainnet addresses
  address public constant SKY_USD_FEED = 0xee10fE5E7aa92dd7b136597449c3d5813cFC5F18;
  address public constant MKR_USD_FEED = 0xec1D1B3b0443256cc3860e24a46F108e699484Aa;

  // Adapter constants (must match contract)
  uint256 public constant EXCHANGE_RATE = 24_000; // 24000:1
  uint8 public constant DECIMALS = 8;
  string public constant DESCRIPTION = 'MKR/USD (calculated)';
  string public constant REPORT_NAME = 'DiscountedMKRSKYAdapter_custom_Ethereum';

  struct ForkParams {
    string network;
    uint256 blockNumber;
  }

  struct PriceParams {
    int256 adapterPrice;
    int256 noDiscountPrice; // MKR price using only exchange rate (no discount)
    int256 referencePrice;
    int256 skyPrice;
    uint256 blockNumber;
    uint256 timestamp;
    int256 discountFromReference; // in BPS (e.g., 600 = 6%)
  }

  ForkParams public forkParams;
  PriceParams[] public prices;

  constructor() {
    forkParams = ForkParams({network: 'mainnet', blockNumber: 24319000});
  }

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl(forkParams.network), forkParams.blockNumber);
  }

  function test_latestAnswer() public {
    IDiscountedMKRSKYAdapter adapter = _createAdapter();

    int256 adapterPrice = adapter.latestAnswer();
    int256 skyPrice = IChainlinkAggregator(SKY_USD_FEED).latestAnswer();
    int256 mkrReferencePrice = IChainlinkAggregator(MKR_USD_FEED).latestAnswer();
    uint256 discount = adapter.discount();

    // Verify price is positive
    assertGt(adapterPrice, 0, 'Adapter price should be positive');

    // Verify formula: MKR = SKY * EXCHANGE_RATE * (1 - discount)
    // forge-lint: disable-next-line(unsafe-typecast)
    int256 expectedPrice = int256(((uint256(skyPrice) * EXCHANGE_RATE) * (1e18 - discount)) / 1e18);
    assertEq(adapterPrice, expectedPrice, 'Price should match formula');

    // Log comparison with actual MKR/USD feed
    emit log_named_int('Adapter MKR price', adapterPrice);
    emit log_named_int('Reference MKR price', mkrReferencePrice);
    emit log_named_int('SKY price', skyPrice);
    emit log_named_uint('Discount (BPS)', discount);
  }

  function test_latestAnswerRetrospective() public {
    uint256 finishBlock = forkParams.blockNumber;

    // Get start block
    uint256 currentBlock = BlockUtils.getStartBlock(
      finishBlock,
      RETROSPECTIVE_DAYS,
      forkParams.network
    );
    vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

    IDiscountedMKRSKYAdapter adapter = _createAdapter();

    // Persist adapter across forks
    vm.makePersistent(address(adapter));

    // Get step
    uint256 step = BlockUtils.getStep(RETROSPECTIVE_STEP, forkParams.network);

    while (currentBlock <= finishBlock) {
      vm.createSelectFork(vm.rpcUrl(forkParams.network), currentBlock);

      int256 adapterPrice = adapter.latestAnswer();
      int256 skyPrice = IChainlinkAggregator(SKY_USD_FEED).latestAnswer();
      int256 mkrReferencePrice = IChainlinkAggregator(MKR_USD_FEED).latestAnswer();
      uint256 discount = adapter.discount();

      // Verify price is positive
      assertGt(adapterPrice, 0, 'Adapter price should be positive');

      // Verify formula holds at each block
      int256 expectedPrice = int256(
        // forge-lint: disable-next-line(unsafe-typecast)
        ((uint256(skyPrice) * EXCHANGE_RATE) * (1e18 - discount)) / 1e18
      );
      assertEq(adapterPrice, expectedPrice, 'Price should match formula');

      // Calculate MKR price without discount (just exchange rate)
      // forge-lint: disable-next-line(unsafe-typecast)
      int256 noDiscountPrice = int256(uint256(skyPrice) * EXCHANGE_RATE);

      // Calculate discount from reference price in BPS
      // discountFromReference = (referencePrice - adapterPrice) * 10000 / referencePrice
      int256 discountFromReference = mkrReferencePrice > 0
        ? ((mkrReferencePrice - adapterPrice) * 10000) / mkrReferencePrice
        : int256(0);

      // Store price data for report
      prices.push(
        PriceParams({
          adapterPrice: adapterPrice,
          noDiscountPrice: noDiscountPrice,
          referencePrice: mkrReferencePrice,
          skyPrice: skyPrice,
          blockNumber: currentBlock,
          timestamp: block.timestamp,
          discountFromReference: discountFromReference
        })
      );

      currentBlock += step;
    }

    // Generate report
    _generateReport();

    vm.revokePersistent(address(adapter));
    vm.createSelectFork(vm.rpcUrl(forkParams.network), finishBlock);
  }

  function _createAdapter() internal returns (IDiscountedMKRSKYAdapter) {
    return new DiscountedMKRSKYAdapter();
  }

  function _generateReport() internal {
    _generateJsonReport();
    _generateMdReport();
  }

  function _generateJsonReport() internal {
    string memory path = string(abi.encodePacked('./reports/out/', REPORT_NAME, '.json'));

    vm.serializeString('root', 'source', DESCRIPTION);
    vm.serializeString('root', 'reference', 'MKR / USD (Chainlink)');
    vm.serializeUint('root', 'decimals', DECIMALS);
    vm.serializeUint('root', 'exchangeRate', EXCHANGE_RATE);

    string memory pricesKey = 'prices';
    string memory content = '{}';
    vm.serializeJson(pricesKey, '{}');

    for (uint256 i = 0; i < prices.length; i++) {
      string memory key = vm.toString(prices[i].blockNumber);
      vm.serializeJson(key, '{}');
      vm.serializeUint(key, 'timestamp', prices[i].timestamp);
      vm.serializeInt(key, 'adapterPrice', prices[i].adapterPrice);
      vm.serializeInt(key, 'noDiscountPrice', prices[i].noDiscountPrice);
      vm.serializeInt(key, 'referencePrice', prices[i].referencePrice);
      vm.serializeInt(key, 'skyPrice', prices[i].skyPrice);
      string memory object = vm.serializeInt(
        key,
        'discountFromReference',
        prices[i].discountFromReference
      );
      content = vm.serializeString(pricesKey, key, object);
    }

    string memory output = vm.serializeString('root', pricesKey, content);
    vm.writeJson(output, path);
  }

  function _generateMdReport() internal {
    string memory path = string(abi.encodePacked('./reports/out/', REPORT_NAME, '.md'));

    // Build markdown content
    string memory md = '# DiscountedMKRSKYAdapter Historic Report\n\n';
    md = string(abi.encodePacked(md, '## Overview\n\n'));
    md = string(
      abi.encodePacked(
        md,
        'This adapter calculates the MKR price based on the SKY price using the formula:\n\n'
      )
    );
    md = string(abi.encodePacked(md, '```\n'));
    md = string(abi.encodePacked(md, 'MKR_price = SKY_price * EXCHANGE_RATE * (1 - DISCOUNT)\n'));
    md = string(abi.encodePacked(md, '```\n\n'));
    md = string(abi.encodePacked(md, '## Configuration\n\n'));
    md = string(abi.encodePacked(md, '| Parameter | Value |\n'));
    md = string(abi.encodePacked(md, '|-----------|-------|\n'));
    md = string(abi.encodePacked(md, '| Adapter Output | MKR/USD (calculated) |\n'));
    md = string(
      abi.encodePacked(
        md,
        '| SKY/USD Feed | [',
        _addressToString(SKY_USD_FEED),
        '](https://etherscan.io/address/',
        _addressToString(SKY_USD_FEED),
        ') |\n'
      )
    );
    md = string(
      abi.encodePacked(
        md,
        '| MKR/USD Feed (Reference) | [',
        _addressToString(MKR_USD_FEED),
        '](https://etherscan.io/address/',
        _addressToString(MKR_USD_FEED),
        ') |\n'
      )
    );
    md = string(
      abi.encodePacked(
        md,
        '| Exchange Rate | ',
        vm.toString(EXCHANGE_RATE),
        ':1 (1 MKR = ',
        vm.toString(EXCHANGE_RATE),
        ' SKY) |\n'
      )
    );
    md = string(abi.encodePacked(md, '| Discount | Dynamic (fetched from MkrSky contract) |\n'));
    md = string(abi.encodePacked(md, '| Decimals | ', vm.toString(DECIMALS), ' |\n'));
    md = string(abi.encodePacked(md, '| Network | Ethereum Mainnet |\n'));
    md = string(
      abi.encodePacked(
        md,
        '| Block Range | ',
        vm.toString(prices[0].blockNumber),
        ' - ',
        vm.toString(prices[prices.length - 1].blockNumber),
        ' |\n'
      )
    );
    md = string(
      abi.encodePacked(
        md,
        '| Date Range | ',
        _formatDate(prices[0].timestamp),
        ' - ',
        _formatDate(prices[prices.length - 1].timestamp),
        ' |\n\n'
      )
    );

    md = string(abi.encodePacked(md, '## Historic Prices\n\n'));
    md = string(
      abi.encodePacked(
        md,
        '| Block | Date | Timestamp | MKR/USD (calculated) | MKR/USD (calculated, no discount) | MKR/USD (Chainlink) | SKY/USD (Chainlink) | Discount from Ref |\n'
      )
    );
    md = string(
      abi.encodePacked(
        md,
        '|-------|------|-----------|----------------------|-----------------------------------|---------------------|---------------------|-------------------|\n'
      )
    );

    for (uint256 i = 0; i < prices.length; i++) {
      md = string(abi.encodePacked(md, _formatRow(prices[i])));
    }

    vm.writeFile(path, md);
  }

  function _formatRow(PriceParams memory p) internal pure returns (string memory) {
    // Split into three parts to avoid stack too deep
    string memory part1 = string(
      abi.encodePacked(
        '| ',
        vm.toString(p.blockNumber),
        ' | ',
        _formatDate(p.timestamp),
        ' | ',
        vm.toString(p.timestamp),
        ' | ',
        _formatPrice(p.adapterPrice)
      )
    );
    string memory part2 = string(
      abi.encodePacked(
        ' | ',
        _formatPrice(p.noDiscountPrice),
        ' | ',
        _formatPrice(p.referencePrice),
        ' | ',
        _formatPrice4Decimals(p.skyPrice)
      )
    );
    string memory part3 = string(
      abi.encodePacked(' | ', _formatBps(p.discountFromReference), ' |\n')
    );
    return string(abi.encodePacked(part1, part2, part3));
  }

  function _formatPrice(int256 price) internal pure returns (string memory) {
    if (price < 0) return '-';
    // forge-lint: disable-next-line(unsafe-typecast)
    uint256 uPrice = uint256(price);
    uint256 dollars = uPrice / 1e8;
    uint256 cents = (uPrice % 1e8) / 1e6;
    return string(abi.encodePacked('$', vm.toString(dollars), '.', _padZeros(cents, 2)));
  }

  function _formatPrice4Decimals(int256 price) internal pure returns (string memory) {
    if (price < 0) return '-';
    // forge-lint: disable-next-line(unsafe-typecast)
    uint256 uPrice = uint256(price);
    uint256 dollars = uPrice / 1e8;
    uint256 decimals = (uPrice % 1e8) / 1e4;
    return string(abi.encodePacked('$', vm.toString(dollars), '.', _padZeros(decimals, 4)));
  }

  function _formatBps(int256 bps) internal pure returns (string memory) {
    if (bps < 0) {
      return
        string(
          abi.encodePacked(
            '-',
            // forge-lint: disable-next-line(unsafe-typecast)
            vm.toString(uint256(-bps) / 100),
            '.',
            // forge-lint: disable-next-line(unsafe-typecast)
            _padZeros(uint256(-bps) % 100, 2),
            '%'
          )
        );
    }
    return
      string(
        abi.encodePacked(
          // forge-lint: disable-next-line(unsafe-typecast)
          vm.toString(uint256(bps) / 100),
          '.',
          // forge-lint: disable-next-line(unsafe-typecast)
          _padZeros(uint256(bps) % 100, 2),
          '%'
        )
      );
  }

  function _padZeros(uint256 value, uint256 length) internal pure returns (string memory) {
    string memory str = vm.toString(value);
    bytes memory bStr = bytes(str);
    if (bStr.length >= length) return str;
    bytes memory padded = new bytes(length);
    uint256 padding = length - bStr.length;
    for (uint256 i = 0; i < padding; i++) {
      padded[i] = '0';
    }
    for (uint256 i = 0; i < bStr.length; i++) {
      padded[padding + i] = bStr[i];
    }
    return string(padded);
  }

  function _formatDate(uint256 timestamp) internal pure returns (string memory) {
    // Convert Unix timestamp to YYYY-MM-DD HH:MM
    (uint256 year, uint256 month, uint256 day) = _daysToDate(timestamp / 86400);
    uint256 secs = timestamp % 86400;
    uint256 hour = secs / 3600;
    uint256 minute = (secs % 3600) / 60;

    return
      string(
        abi.encodePacked(
          vm.toString(year),
          '-',
          _padZeros(month, 2),
          '-',
          _padZeros(day, 2),
          ' ',
          _padZeros(hour, 2),
          ':',
          _padZeros(minute, 2)
        )
      );
  }

  function _addressToString(address addr) internal pure returns (string memory) {
    return vm.toString(addr);
  }

  // Convert days since Unix epoch to year/month/day
  // Algorithm from https://howardhinnant.github.io/date_algorithms.html
  function _daysToDate(
    uint256 _days
  ) internal pure returns (uint256 year, uint256 month, uint256 day) {
    unchecked {
      // forge-lint: disable-next-line(unsafe-typecast)
      int256 z = int256(_days) + 719468;
      int256 era = (z >= 0 ? z : z - 146096) / 146097;
      int256 doe = z - era * 146097;
      int256 yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
      int256 y = yoe + era * 400;
      int256 doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
      int256 mp = (5 * doy + 2) / 153;
      int256 d = doy - (153 * mp + 2) / 5 + 1;
      int256 m = mp + (mp < 10 ? int256(3) : int256(-9));
      y += (m <= 2 ? int256(1) : int256(0));
      // forge-lint: disable-next-line(unsafe-typecast)
      year = uint256(y);
      // forge-lint: disable-next-line(unsafe-typecast)
      month = uint256(m);
      // forge-lint: disable-next-line(unsafe-typecast)
      day = uint256(d);
    }
  }
}
