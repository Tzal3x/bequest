# ⏳ bequest

## WARNING: Still in development. Do not use in production. This is only available on testnet.

A censorship resistant deadman's switch inspired by [killcord](https://killcord.io/).

Bequest is a tool used to build resilient deadman's switches for releasing encrypted payloads.

In its default configuration, bequest leverages [sui](https://sui.io/) and [walrus](https://docs.walrus.site/) for censorship resistance.

The bequest project owner hides a secret key from the world by checking in to the bequest smart contract on sui.
If the owner stops checking in after a period of time, the bequest is triggered and the secret key that decrypts an encrypted payload is published.

## Requirements

You need to have installed the [sui](https://docs.sui.io/references/cli/client) and [walrus](https://docs.walrus.site/) cli.

Use the following command to get some sui for the faucet in order for the following steps to work `sui client faucet`.

## Usage

Create a new bequest:

```bash
chmod u+x bequest.sh && source bequest.sh
```

This will create a new bequest smart contract and set some environment variables.

Use `./bequest.sh -h` to learn more about the available commands and how to use them.
