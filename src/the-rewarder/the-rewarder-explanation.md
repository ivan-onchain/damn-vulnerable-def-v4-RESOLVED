# `TheRewarderDistributor::claimRewards` function fails in validate when the token to claim the rewards is repeated.

`TheRewarderDistributor::claimRewards` only validate if a reward was claimed in 2 scenarios:
1. When token is different to the previously validated token, or when it is the first token of the array as the token is alway zero in the first run.
2. When the token is the last token of the array.

But this function lack on validate when the token is the same than before. User can claim rewards for the same token but with a different batch number, but this function doesn't validate that scenario.

The highlighted line in the else of the of effectively mark the position in the bitset but it is not validated.

With this lack of validation I was able to pass an array with multiple claims of the same token (dvt) followed by multiple claims of weth token. Therefore the validation only happen in the first dvt token and in the then in the first weth and omit the rest of repeated claims.
 You can check it in the unit test of the challenge.

```js
   function claimRewards(Claim[] memory inputClaims, IERC20[] memory inputTokens) external {
        Claim memory inputClaim;
        IERC20 token;
        uint256 bitsSet; // accumulator
        uint256 amount;

        for (uint256 i = 0; i < inputClaims.length; i++) {
            inputClaim = inputClaims[i];

            uint256 wordPosition = inputClaim.batchNumber / 256;
            uint256 bitPosition = inputClaim.batchNumber % 256;

            if (token != inputTokens[inputClaim.tokenIndex]) {
                if (address(token) != address(0)) {
                    if (!_setClaimed(token, amount, wordPosition, bitsSet)) revert AlreadyClaimed();
                }

                token = inputTokens[inputClaim.tokenIndex];
                bitsSet = 1 << bitPosition; // set bit at given position
                amount = inputClaim.amount;
            } else {
@>              bitsSet = bitsSet | 1 << bitPosition;
@>              amount += inputClaim.amount;
            }

            // for the last claim
            if (i == inputClaims.length - 1) {
                if (!_setClaimed(token, amount, wordPosition, bitsSet)) revert AlreadyClaimed();
            }

            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, inputClaim.amount));
            bytes32 root = distributions[token].roots[inputClaim.batchNumber];

            if (!MerkleProof.verify(inputClaim.proof, root, leaf)) revert InvalidProof();

            inputTokens[inputClaim.tokenIndex].transfer(msg.sender, inputClaim.amount);
        }
    }
```