# Awacoin Nim

A Nim client of <https://github.com/hiyoteam/awacoin>.

Supports:

- Registering accounts
- Geting account info
- Transferring coins
- Mining coins
- Multi thread mining
- Faster than official python client

Doesn't support:

- Custom server URL (Can be done through editing source code)

Build:

```shell
nim c -d:release awacoin.nim
```

Usage:

```shell
awacoin mine [number_of_threads]

awacoin info [accounts...]

awacoin transfer <account> <amount>
```

## Hashcat Miner

Uses hashcat to mine awacoin. Fast![^1]

Build:

```shell
nim c -d:release hashcat_miner.nim
```

Usage:

```shell
hashcat_miner
```

Notice:

You must have hashcat installed.

You need to create a `.hashcatdir` file at where the miner is, and write your hashcat dir into it.

Example file content:

```
Path/To/hashcat-6.2.6
```

[^1]: On my computer, 12 threads in one process is the most efficient. When Awacoin Nim uses 12 threads, its efficiency is close to Awacoin Nim Hashcat Miner.
