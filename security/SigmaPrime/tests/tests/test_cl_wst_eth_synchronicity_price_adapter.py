from brownie import reverts

"""
Tests for `CLwstETHSynchronicityPriceAdapter.sol`
"""

# Tests constructor
def test_constructor(owner, steth, ChainlinkAggregatorMock, CLwstETHSynchronicityPriceAdapter):
    ## Setup
    base_price = 1123 * 10**8  # 1 ETH : 1,123 USD
    peg_to_base = owner.deploy(ChainlinkAggregatorMock, base_price, 1)  # ETH / USD

    asset_to_peg_decimals = 18
    asset_price = 982 * 10**asset_to_peg_decimals // 10**3  # 0.982 stETH : 1 ETH
    asset_to_peg = owner.deploy(ChainlinkAggregatorMock, asset_price, 1)  # stETH / ETH
    asset_to_peg.setDecimals(asset_to_peg_decimals)

    ## Action
    decimals = 8
    price_adapter = owner.deploy(
        CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth
    )

    ## Verification
    assert price_adapter.DECIMALS() == 8
    assert price_adapter.DENOMINATOR() == 10 ** (8 + 18)
    assert price_adapter.MAX_DECIMALS() == 18
    assert price_adapter.PEG_TO_BASE() == peg_to_base
    assert price_adapter.ASSET_TO_PEG() == asset_to_peg

    assert price_adapter.STETH() == steth
    assert price_adapter.RATIO_DECIMALS() == 18


# Tests constructor when any of the decimals are larger than max
def test_constructor(
    custom_error, owner, steth, ChainlinkAggregatorMock, CLwstETHSynchronicityPriceAdapter
):
    ## Setup
    peg_to_base = owner.deploy(ChainlinkAggregatorMock, 99, 1)  # ETH / USD
    asset_to_peg = owner.deploy(ChainlinkAggregatorMock, 99, 1)  # stETH / ETH

    ## Action
    decimals = 19
    peg_to_base.setDecimals(8)
    asset_to_peg.setDecimals(8)
    with reverts(custom_error("DecimalsAboveLimit")):
        owner.deploy(CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth)

    ## Action
    decimals = 8
    peg_to_base.setDecimals(19)
    asset_to_peg.setDecimals(8)
    with reverts(custom_error("DecimalsAboveLimit")):
        owner.deploy(CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth)

    ## Asset
    decimals = 8
    peg_to_base.setDecimals(8)
    asset_to_peg.setDecimals(19)
    with reverts(custom_error("DecimalsAboveLimit")):
        owner.deploy(CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth)


# Test `lastestAnswer()`
def test_latest_answer(owner, steth, ChainlinkAggregatorMock, CLwstETHSynchronicityPriceAdapter):
    ## Setup
    base_price = 1123 * 10**8  # 1 ETH : 1,123 USD
    peg_to_base = owner.deploy(ChainlinkAggregatorMock, base_price, 1)  # ETH / USD

    asset_to_peg_decimals = 9
    asset_price = 982 * 10**asset_to_peg_decimals // 10**3  # 0.982 stETH : 1 ETH
    asset_to_peg = owner.deploy(ChainlinkAggregatorMock, asset_price, 1)  # stETH / ETH
    asset_to_peg.setDecimals(asset_to_peg_decimals)

    decimals = 7
    price_adapter = owner.deploy(
        CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth
    )

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    ratio = steth.getPooledEthByShares(10**18)
    steth_to_usd = asset_price * base_price * 10**7 // 10 ** (9 + 8)

    assert answer == steth_to_usd * ratio // 10**18


# Test `lastestAnswer()` negative answers
def test_latest_answer_negative(
    owner, steth, ChainlinkAggregatorMock, CLwstETHSynchronicityPriceAdapter
):
    ## Setup
    base_price = -1  # negative
    peg_to_base = owner.deploy(ChainlinkAggregatorMock, base_price, 1)  # ETH / USD

    asset_price = 982 * 10**5  # 0.982 stETH : 1 ETH
    asset_to_peg = owner.deploy(ChainlinkAggregatorMock, asset_price, 1)  # stETH / ETH

    decimals = 8
    price_adapter = owner.deploy(
        CLwstETHSynchronicityPriceAdapter, peg_to_base, asset_to_peg, decimals, steth
    )

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    assert answer == 0

    ## Setup
    peg_to_base.setAnswer(10**8)
    asset_to_peg.setAnswer(-1)

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    assert answer == 0
