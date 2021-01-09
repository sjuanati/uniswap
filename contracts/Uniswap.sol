// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./IUniswap.sol";
import "./IERC20.sol";

// @Dev: Market price should be calculated off-chain with Uniswap sdk
contract Uniswap {
    // Smart contract addresses at Ropsten
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant DAI_ADDRESS =
        0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address internal constant UNI_ADDRESS =
        0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address internal constant WETH_ADDRESS =
        0xc778417E063141139Fce010982780140Aa0cD5Ab;

    IUniswap uniswap;

    constructor() {
        uniswap = IUniswap(UNISWAP_ROUTER_ADDRESS);
    }

    // Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by the path
    function swapExactTokensForTokens(uint256 amountIn) external {
        address tokenIn = DAI_ADDRESS;
        address tokenOut = UNI_ADDRESS;

        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountIn);

        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountIn);

        // using 'now' for convenience, but should be sent from frontend!
        uint256 deadline = block.timestamp + 15;

        // Calculates the amount out
        uint256[] memory amountOutMin = uniswap.getAmountsOut(amountIn, path);

        uniswap.swapExactTokensForTokens(
            amountIn,
            amountOutMin[1],
            path,
            msg.sender,
            deadline
        );
    }

    // Receive an exact amount of output tokens for as few input tokens as possible, along the route determined by the path.
    function swapTokensForExactTokens(uint256 amountOut) external {
        address tokenIn = DAI_ADDRESS;
        address tokenOut = UNI_ADDRESS;

        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Calculates the minimum amount in
        uint256[] memory amountInMin = uniswap.getAmountsIn(amountOut, path);

        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountInMin[0]);

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountInMin[0]);

        // using 'now' for convenience, but should be sent from frontend!
        uint256 deadline = block.timestamp + 15;

        uniswap.swapTokensForExactTokens(
            amountOut,
            amountInMin[0],
            path,
            msg.sender,
            deadline
        );
    }

    // Swaps an exact amount of tokens for as much ETH as possible, along the route determined by the path
    function swapExactTokensForETH(
        //address token,
        uint256 amountIn //uint256 deadline // uint256 amountOutMin
    ) external {
        // for testing, DAI only
        address token = DAI_ADDRESS;

        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(token, msg.sender, address(this), amountIn);

        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(token).approve(address(uniswap), amountIn);

        // using 'now' for convenience, but should be sent from frontend!
        uint256 deadline = block.timestamp + 15;

        // Calculates the amount out
        uint256[] memory amountOutMin = uniswap.getAmountsOut(amountIn, path);

        // Swap Tokens for ETH
        uniswap.swapExactTokensForETH(
            amountIn, // The amount of input tokens to send
            amountOutMin[1], // The minimum amount of output tokens that must be received for the transaction not to revert (amountOutMin must be retrieved from an oracle of some kind)
            path, // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity
            msg.sender, // Recipient: Ether to be sent directly to the sender. If smart contract, it must be able to receive ETH!
            deadline // Unix timestamp after which the transaction will revert
        );
    }

    // Receive an exact amount of tokens for as little ETH as possible, along the route determined by the path. Leftover ETH, if any, is returned to msg.sender
    function swapETHForExactTokens(
        //address token,
        uint256 amountOut //uint256 deadline
    ) external payable {
        address token = DAI_ADDRESS;
        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, but should be sent from frontend!
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = token;
        // Swap ETH for Tokens
        uniswap.swapETHForExactTokens{value: msg.value}(
            amountOut, // The amount of tokens to receive
            path, // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity
            msg.sender, // Recipient of the output tokens
            deadline // Unix timestamp after which the transaction will revert
        );
    }

    function _transferToken(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        require(
            IERC20(token).allowance(from, to) >= amount,
            "Uniswap approval is missing"
        );
        IERC20(token).transferFrom(from, to, amount);
    }

    // important to receive ETH
    receive() external payable {}
}

/* Sample input for swapExactTokensForETH:
token:		    0xad6d458402f60fd3bd25163575031acdce07538d
amountIn: 		2807740571120975129
amountOutMin:	2807740571120975
deadline:		1610214892
*/

/* Sample input for swapETHForExactTokens:
token:		    0xad6d458402f60fd3bd25163575031acdce07538d
amountOut: 		1000000000000000000
deadline:		1610214892
msg.value       
*/
