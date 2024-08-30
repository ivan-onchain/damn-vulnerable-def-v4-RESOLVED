# `SideEntranceLenderPool::deposit()` allows increase contract ETH balance.

The only requirement to have an success flash-loan is the final balance has to be greater than the balance before the external call.
```js
    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

@>      if (address(this).balance < balanceBefore) {
            revert RepayFailed();
        }
    }
```
However we can use the flash-loan receiver to return the eth to the `SideEntranceLenderPool` contract by calling the deposit function, the side entrance function. This would restore the eth balance in the contract and also that amount is awarded to the caller, in this case the `SideEntranceReceiver` contract, who is able to call the `withdraw` function to claim it awarded balance.

***note*** : `SideEntranceReceiver` should have a anonymous function to avoid revert transfer error.