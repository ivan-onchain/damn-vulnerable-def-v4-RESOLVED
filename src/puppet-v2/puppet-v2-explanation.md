# Trusting in a unique source of price is not a good idea.

The issue at hand is that the pool relies solely on one source for price calculations, which makes it vulnerable to manipulation.

If you refer to the test/puppetV2.t.sol file, you'll notice I started by exchanging `PLAYER_INITIAL_TOKEN_BALANCE` for `WETH`. Given that this swap operates with limited reserves, it becomes straightforward to manipulate the price through slippage, essentially unbalancing the swap with my transaction.

Following this, the player's `WETH` balance stood at `29.9e18`. I then calculated how much `WETH` was required to borrow the entire token pool balance, which came out to be `29.4e18`. This amount is significantly less than what was previously needed, illustrating the impact of price slippage, especially when this swap is the sole price reference for the pool.

Subsequently, I executed a final swap to drain all the tokens from the pool.
