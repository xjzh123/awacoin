# Awacoin Nim

A Nim client of Hiyoteam/awacoin.

Supports:

- Registering accounts
- Geting account info
- Transferring coins
- Mining coins
- Multi thread mining
- Faster than official python client

Doesn't support:

- Custom server URL (Can be done through editing source code)

Usage:

awacoin mine [number of threads]

awacoin info [account1] [account2] ...

awacoin transfer [account] [amount]

## Hashcat Miner

Uses hashcat to mine awacoin. Fast![^1]

Usage:

hashcat_miner

Notice:

You need to create a `.hashcatdir` file at where the miner is, and write your hashcat dir into it.

Example file content:

```
Path/To/hashcat-6.2.6
```

[^1]: On my computer, 12 threads in one process is the most efficient. When Awacoin Nim uses 12 threads, its efficiency is close to Awacoin Nim Hashcat Miner.
