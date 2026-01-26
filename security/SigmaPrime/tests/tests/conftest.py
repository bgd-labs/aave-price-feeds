import types
import brownie
import pytest
from brownie import web3


@pytest.fixture(scope="module", autouse=True)
def mod_isolation(module_isolation):
    """Snapshot ganache at start of module."""
    pass


@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    """Snapshot ganache before every test function call."""
    pass


@pytest.fixture(scope="session")
def constants():
    """Parameters used in the default setup/deployment, useful constants."""
    return types.SimpleNamespace(
        ZERO_ADDRESS=brownie.ZERO_ADDRESS,
        STABLE_SUPPLY=1_000_000 * 10**6,
        MAX_UINT256=2**256 - 1,
    )


# Pytest Adjustments
####################

# Copied from
# https://docs.pytest.org/en/latest/example/simple.html?highlight=skip#control-skipping-of-tests-according-to-command-line-option


def pytest_addoption(parser):
    parser.addoption("--runslow", action="store_true", default=False, help="run slow tests")


def pytest_configure(config):
    config.addinivalue_line("markers", "slow: mark test as slow to run")


def pytest_collection_modifyitems(config, items):
    if config.getoption("--runslow"):
        # --runslow given in cli: do not skip slow tests
        return
    skip_slow = pytest.mark.skip(reason="need --runslow option to run")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(skip_slow)


## Account Fixtures
###################


@pytest.fixture(scope="session")
def owner(accounts):
    """Account used as the default owner/guardian."""
    return accounts[0]


@pytest.fixture(scope="session")
def alice(accounts):
    return accounts[2]


@pytest.fixture(scope="session")
def bob(accounts):
    return accounts[3]


@pytest.fixture(scope="session")
def carol(accounts):
    return accounts[4]


# Mainnet stETH as IStETH
@pytest.fixture(scope="session")
def steth(interface):
    return interface.IStETH("0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84")


## Utils
#########


@pytest.fixture(scope="session")
def custom_error():
    def method(error_name, var_values=None):
        try:
            # we search using regex and make sure we only have one match
            var_types = re.findall(r"\(.*?\)", error_name)[0]
            # Remove brackets if it only has one variable
            if "," not in var_types:
                var_types = var_types[1:-1]
        except:
            # This has no brackets, so we add them
            # We do this to maintain compatibility with the old custom_error
            error_name = error_name + "()"

        sig = web3.solidityKeccak(["string"], [error_name])[:4]

        if var_values is None:
            return "typed error: " + str(web3.toHex(sig))
        else:
            return (
                "typed error: "
                + str(web3.toHex(sig))
                + str(web3.toHex(encode_single(var_types, var_values)))[2:]
            )

    return method
