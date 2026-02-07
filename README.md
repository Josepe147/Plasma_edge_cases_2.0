## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


					Interesting part

Tests Overview

The following unit tests validate the core escrow link functionality.

testCreateAndClaim

Verifies the happy path. A sender creates a link by locking ETH, and the recipient successfully claims the funds by revealing the correct secret.

testWrongSecretFails

Ensures that providing an incorrect secret when attempting to claim a link results in a revert.

testCannotClaimTwice

Confirms that each escrow link can only be claimed once and cannot be double-spent.

testCancelAfterExpiry

Checks that the original sender can cancel an unclaimed link and recover funds after the link’s expiry time has passed.

testCancelBeforeExpiryFails

Ensures that the sender cannot cancel a link before its expiry, preserving the recipient’s claim window.