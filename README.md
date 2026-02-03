# Aave Price Oracle Adapters

## Specification

## Adapters

### Price cap adapters

### Synchronicity adapters

### Misc Adapters

---

## Usage

### Setup

```sh
cp .env.example .env
make install # forge install && npm install
make build # forge build --sizes
```

### Test

```sh
  make test
  make test-zksync # zksync tests
```

⚠️ Important: To properly run adapters tests, you must execute them against an archive node RPC like Alchemy or Quicknode.

## Security Reviews

- Certora security report: [2024](./security/Certora/Certora%20Review.pdf)
- SigmaP security report: [2024](./security/sigmap/audit-report.md)

## License

Copyright © 2026, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

The default license of this repository is [BUSL1.1](./LICENSE), but all interfaces and the content of the [libs folder](./src/contracts/libs/) and [Polygon tunnel](./src/contracts/adapters/polygon/tunnel/) folders are open source, MIT-licensed.

**IMPORTANT**. The BUSL1.1 license of this repository allows for any usage of the software, if respecting the _Additional Use Grant_ limitations, forbidding any use case damaging anyhow the Aave DAO's interests.
