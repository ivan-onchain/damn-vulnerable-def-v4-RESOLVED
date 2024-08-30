## Strict requirement for equivalence between token balance and share balance.

The UnstoppableVault contract assumes that the only way to increase or decrease the token balance in the vault is through the deposit and withdraw functions, ignoring the fact that anyone can use the token's transfer function to send tokens directly to the vault. One of the requirements for executing a flash loan is that the token balance must equal the share balance. This assumption opens the door for an attacker to send tokens to the vault, disrupting this balance and effectively halting the contract's functionality.

run it to prove the attack
```shell
forge test  --mc UnstoppableChallenge
```

```js 
  function flashLoan(IERC3156FlashBorrower receiver, address _token, uint256 amount, bytes calldata data)
        external
        returns (bool)
    {
        if (amount == 0) revert InvalidAmount(0); // fail early
        if (address(asset) != _token) revert UnsupportedCurrency(); // enforce ERC3156 requirement
        uint256 balanceBefore = totalAssets();
    >@  if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement

        // transfer tokens out + execute callback on receiver
        ERC20(_token).safeTransfer(address(receiver), amount);

        // callback must return magic value, otherwise assume it failed
        uint256 fee = flashFee(_token, amount);
        if (
            receiver.onFlashLoan(msg.sender, address(asset), amount, fee, data)
                != keccak256("IERC3156FlashBorrower.onFlashLoan")
        ) {
            revert CallbackFailed();
        }

        // pull amount + fee from receiver, then pay the fee to the recipient
        ERC20(_token).safeTransferFrom(address(receiver), address(this), amount + fee);
        ERC20(_token).safeTransfer(feeRecipient, fee);

        return true;
    }
```