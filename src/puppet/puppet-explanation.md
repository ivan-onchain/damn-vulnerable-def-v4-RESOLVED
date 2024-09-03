# How to manipulate the price source as a puppet.


The `PuppetPool::calculateDepositRequired `function is the key to solving this challenge. If you examine this function, you'll notice that it calculates the required deposit based on the ETH balance and the token balance of the Uniswap exchange contract. This raises an important question: Can these balances be manipulated arbitrarily? The answer is yes, they can.

To follow the next steps, refer to the `test/Poppet.t.sol` file:

Here’s the plan: By reducing the ETH balance and increasing the token balance, we can lower the required ETH collateral. In other words, we can manipulate the borrowing rate to the point where we can borrow all the tokens in the pool (100,000e18) with minimal ETH (less than 25 ETH).

First, remove nearly all the ETH from the exchange contract. Use `.getTokenToEthOutputPrice()` to determine how many tokens are needed to withdraw that amount of ETH.
Second, with that amount of tokens, swap them for ETH using the `tokenToEthSwapOutput()` function. The goal here is to reduce the ETH balance.
Third, transfer the remaining tokens you have to the exchange contract to inflate its token balance.
Next, calculate the required deposit to borrow the entire token balance of the pool (100,000e18) by calling the `calculateDepositRequired() `function. You'll see that the required deposit is now less than 20 ETH (19.801980198019800000e18), which we have in our balance. Initially, the required deposit was double the pool’s ETH balance (200,000e18), but now it’s under 20 ETH.
Finally, proceed with the borrow.