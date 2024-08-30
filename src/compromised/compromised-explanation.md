# Leaked private keys of source price oracles.

That strange response from the server are two private keys of two of the three price source oracles of the Exchange in a bytecode format.

To get the string text from the byte code use this bytes to string Converter [web tool](https://onlinestringtools.com/convert-bytes-to-string#examples).
As the string you got has a base64 encode you have to decode it to know what it is hiding. You can do it with this [web tool](https://www.base64decode.org/) for base64 decoding.

If you do it for every pair of byte code you are going to get 2 numbers in hex format that looks like a ethereum private keys.

Effectively those are private keys of two of the three price source oracles that you can use to post the price of NFTs at your discretion.

With the ability to change the NFT prices you can buy it at the price that you desire and then sell it at a  much higher price. Check `compromised/Compromised.t.sol` file to see how I did it.