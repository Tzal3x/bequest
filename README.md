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

### Example

You decide to create a bequest: You need to upload a file to a decentralized censorship resinstant store like walrus.
That file will be encrypted using a symmetric key.
If you stop checking in to the bequest smart contract, the symmetric key will be published, and everyone will be able to see
what you had uploaded.

Initialize the smart contract:

```bash
chmod u+x bequest.sh && source bequest.sh
```

This will create a new bequest smart contract and set some environment variables.

Then you can upload the file to walrus:

```bash
./bequest.sh upload my_important_file.txt
```

The file can be anything, from a text file to an image. Walrus stores the file and returns an identifier.
You will be asked for a password which will be used to encrypt the file.
You can find information from your uploads at `file-uploads.log`.

Now run the watch command:

```bash
./bequest watch <password> <resourcesUrl> <releaseMessage>
```

The `<password>` asked is the one you used to encrypt the file.

The `<resourcesUrl>` is used in case you host a site that you want to be checked by others in case your
secrets get published.

The `<releaseMessage>` is a message that you would like to be accompanied with the release of the secret.

When the secret is published, what actually happens is that a new Sui object is created and sent to your admin address.
It will contain the arguments you passed to the watch command.

To keep the secrets being secrets, keep checking in with the bequest smart contract:

```bash
./bequest checkin
```
