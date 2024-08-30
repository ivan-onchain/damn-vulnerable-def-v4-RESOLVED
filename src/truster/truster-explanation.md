# `TrusterLenderPool` contract gives the power to take actions on their behalf who take a flash-loan.

`TrusterLenderPool::flahsLoan` function implement a low level call give to the target to take action in their behalf, actions like an approval to the target address behalf. Action which would allow to the target address drain the funds after the flash-loan 

```js
 function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
        external
        nonReentrant
        returns (bool)
    {
        uint256 balanceBefore = token.balanceOf(address(this));

        token.transfer(borrower, amount);
@>        target.functionCall(data);

        if (token.balanceOf(address(this)) < balanceBefore) {
            revert RepayFailed();
        }

        return true;
    }
```