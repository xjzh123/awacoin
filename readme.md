# Awacoin Nim

A Nim client of Hiyoteam/awacoin.

Supports:

- Registering accounts
- Geting account info
- Transferring coins
- Mining coins
- Multi thread mining
- Faster than official python client (till 2023.8.3 22:37)

Doesn't support:

- Custom server URL (Can be done through editing source code)

Usage:

awacoin mine [number of threads]

awacoin info [account1] [account2] ...

awacoin transfer [account] [amount]

## Hashcat Miner

Uses hashcat to mine awacoin. Fast!

Usage:

hashcat_miner

Notice:

You need to create a `.hashcatdir` file at where the miner is, and write your hashcat dir into it.

Example file content:

```
Path/To/hashcat-6.2.6
```
