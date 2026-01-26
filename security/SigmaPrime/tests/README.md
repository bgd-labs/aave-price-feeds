# Brownie Tests

## Running the Tests

### Docker

The tests can be run in Docker via the script replace `<INFURA_URL>` with any mainnet RPC endpoint (doesn't have to be Infura) e.g. https://mainnet.infura.io/v3/123456789.

```sh
./run_docker_tests.sh <INFURA_URL>
```

### Brownie

Alternatively, the tests can be run directly with brownie.

```sh
brownie test
```

Note you can add all the pytest parameters/flags e.g.

- `tests/test_deploy.py`
- `-s`
- `-v`
- `-k <test_name>`

### Installing Brownie

Brownie can be installed via

```sh
pip install eth-brownie
```

Alternatively all required packages can be installed via

```sh
pip install -r requirements.txt
```

### Mainnet Fork Setup

Add a fork of Ethereum Mainnet to brownie. Update <INFURA_ID> with your Infura ID or to use another provider modify the URL accordingly.
Note that Infura appends `@16286330` to specify block 16286330.

```
brownie networks add development mainnet-fork-16286330 cmd=ganache-cli host=http://127.0.0.1 fork=https://mainnet.infura.io/v3/<INFURA_ID>@16286330 accounts=10 mnemonic=brownie port=8545
```

## Writing tests

The same as the old `pytest` style. Add a file named `test_<blah>.py`
to the folder `./tests/`.

Each individual test case in the file created above must be a function named
`test_<test_case>()`.

Checkout the [brownie docs](https://eth-brownie.readthedocs.io/en/stable/tests-pytest-intro.html)
for details on the syntax.

Note `print(dir(Object))` is a handy way to see available methods for a python object.
