# ⏳ bequest 
A censorship resistant deadman's switch inspired by [killcord](https://killcord.io/).

Bequest is a tool used to build resilient deadman's switches for releasing encrypted payloads. 

In its default configuration, bequest leverages [sui](https://sui.io/) and [walrus](https://docs.walrus.site/) for censorship resistance. 

The bequest project owner hides a secret key from the world by checking in to the bequest smart contract on sui. 
If the owner stops checking in after a period of time, the bequest is triggered and the secret key that decrypts an encrypted payload is published.
