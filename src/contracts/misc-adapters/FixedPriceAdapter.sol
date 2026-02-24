// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IFixedPriceAdapter, IACLManager} from '../../interfaces/IFixedPriceAdapter.sol';

/**
 * @title FixedPriceAdapter
 * @author BGD Labs
 * @notice Price adapter using a fixed hardcoded price
 */
contract FixedPriceAdapter is IFixedPriceAdapter {
  /// @inheritdoc IFixedPriceAdapter
  uint8 public immutable DECIMALS;

  /// @inheritdoc IFixedPriceAdapter
  IACLManager public immutable ACL_MANAGER;

  int256 internal _price;
  string internal _description;

  constructor(
    address _aclManager,
    uint8 _decimals,
    int256 _adapterPrice,
    string memory _adapterDescription
  ) {
    if (address(_aclManager) == address(0)) revert ACLManagerIsZeroAddress();

    ACL_MANAGER = IACLManager(_aclManager);
    DECIMALS = _decimals;
    _setPrice(_adapterPrice);
    _description = _adapterDescription;
  }

  /// @inheritdoc IFixedPriceAdapter
  function description() external view returns (string memory) {
    return _description;
  }

  /// @inheritdoc IFixedPriceAdapter
  function price() external view returns (int256) {
    return _price;
  }

  /// @inheritdoc IFixedPriceAdapter
  function decimals() external view returns (uint8) {
    return DECIMALS;
  }

  /// @inheritdoc IFixedPriceAdapter
  function latestAnswer() external view virtual returns (int256) {
    return _price;
  }

  /// @inheritdoc IFixedPriceAdapter
  function setPrice(int256 newPrice) external {
    if (!ACL_MANAGER.isPoolAdmin(msg.sender)) revert CallerIsNotPoolAdmin();
    _setPrice(newPrice);
  }

  /**
   * @notice updates the fixed price
   * @param newPrice the new fixed price to set
   */
  function _setPrice(int256 newPrice) internal {
    if (newPrice < 0) revert InvalidPrice();
    int256 currentPrice = _price;
    _price = newPrice;

    emit FixedPriceUpdated(currentPrice, newPrice);
  }
}
