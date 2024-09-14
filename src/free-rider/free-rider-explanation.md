# Exploit logic error with flash swaps that UniswapPairV2 offers.

The error is in the 108 of the `FreeRiderNFTMarketplace` contract where the funds are sent to the new owner of the token. It is a logic error because the funds should be sent to the previous owner, who is selling the token, not the the new owner who is paying for it.

These could be the recommended modification to fix this logic error:

```diff
    function _buyOne(uint256 tokenId) private {
        uint256 priceToPay = offers[tokenId];
        if (priceToPay == 0) {
            revert TokenNotOffered(tokenId);
        }

        if (msg.value < priceToPay) {
            revert InsufficientPayment();
        }

        --offersCount;

        // transfer from seller to buyer
        DamnValuableNFT _token = token; // cache for gas savings

+       address previousOwner = _token.ownerOf(tokenId);
+       _token.safeTransferFrom(previousOwner, msg.sender, tokenId);
-       _token.safeTransferFrom(_token.ownerOf(tokenId), msg.sender, tokenId);

        // pay seller using cached token
+       payable(previousOwner).sendValue(priceToPay);
-       payable(_token.ownerOf(tokenId)).sendValue(priceToPay);

        emit NFTBought(msg.sender, tokenId, priceToPay);
    }
```

As the funds was returned to the buyer, the buyer could use the same funds to buy again and again.
However we only have 0.1 ether which is not enough to do the first buy, therefore we used the flash swap feature that Uniswap provides.
A flash swap is basically a swap where you have to return the swapped fund in the same transaction, it works very similar to the flash loan.

You can see in the `FlashSwap` contract how the swap is executed. `UniswapPairV2` requires to implement the `uniswapV2Call` function to perform the what you need to do with the swapped funds(15 ether), in this case buy the nft, to finally return them, but everything in the same transaction.