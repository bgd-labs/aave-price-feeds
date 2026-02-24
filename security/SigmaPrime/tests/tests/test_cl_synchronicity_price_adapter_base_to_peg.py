from brownie import reverts

"""
Tests for `CLSynchronicityPriceAdapterBaseToPeg.sol`
"""

# Test `constructor()`
def test_deployment(accounts, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8  # 1 ETH : 2,123 USD
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)  # ETH / USD
    asset_price = 101 * 10**6  # 1 USDC : 1.01 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)  # USDC / USD

    ## Action
    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(
        CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
    )

    ## Verification
    assert price_adapter.DECIMALS() == price_adapter_decimals
    assert price_adapter.BASE_TO_PEG() == base_to_peg
    assert price_adapter.ASSET_TO_PEG() == asset_to_peg


# Test `constructor()` when decimals breach limit
def test_constructor_decimals_limit(
    accounts, custom_error, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock
):
    ## Setup
    base_price = 2123 * 10**8  # 1 ETH : 2,123 USD
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    asset_price = 101 * 10**6  # 1 USDC : 1.01 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    ## Action
    price_adapter_decimals = 77
    with reverts(custom_error("DecimalsAboveLimit")):
        accounts[0].deploy(
            CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
        )

    ## Action
    price_adapter_decimals = 8
    base_to_peg.setDecimals(19)
    with reverts(custom_error("DecimalsAboveLimit")):
        accounts[0].deploy(
            CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
        )


# Test `constructor()` when decimals are not equal
def test_constructor_decimals_equal(
    accounts, custom_error, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock
):
    ## Setup
    base_price = 2123 * 10**8  # 1 ETH : 2,123 USD
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**6  # 1 USDC : 1.01 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    ## Action
    asset_to_peg.setDecimals(9)
    price_adapter_decimals = 8
    with reverts(custom_error("DecimalsNotEqual")):
        accounts[0].deploy(
            CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
        )


# Test `latestAnswer()`
def test_latest_answer(accounts, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8  # 1 ETH : 2,123 USD
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**6  # 1 USDC : 1.01 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(
        CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
    )

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    multiplier = 10**price_adapter_decimals
    assert answer == asset_price * multiplier // base_price
    assert answer == 475_741_874_705_605


# Test `latestAnswer()` when feed answers are negative or zero
def test_latest_answer_zero(
    accounts, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock
):
    ## Setup
    base_price = -1 # negative price
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 10**8
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 8
    price_adapter = accounts[0].deploy(
        CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
    )

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    assert answer == 0

    ## Setup
    base_to_peg.setAnswer(10**8)
    asset_to_peg.setAnswer(0) # zero price

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    assert answer == 0


# Test `latestAnswer()` multiplication overflow
def test_latest_answer_multiplication_overflow(
    accounts, CLSynchronicityPriceAdapterBaseToPeg, ChainlinkAggregatorMock
):
    ## Setup
    base_price = 2123 * 10**8  # 1 ETH : 2,123 USD
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**65  # will cause a multiplication overflow
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(
        CLSynchronicityPriceAdapterBaseToPeg, base_to_peg, asset_to_peg, price_adapter_decimals
    )

    ## Action
    with reverts():
        answer = price_adapter.latestAnswer()
