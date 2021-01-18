// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./IUniswap.sol";
import "./IERC20.sol";

contract Uniswap {
    // Smart contract addresses at Ropsten
    address internal constant UNISWAP_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswap uniswap;

    constructor() {
        uniswap = IUniswap(UNISWAP_ROUTER_ADDRESS);
    }

    // Adds liquidity to an ERC-20⇄ERC-20 pool
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external {

        // move desired amounts for tokens A & B from User to this Contract 
        // (User's approval is required before the transfer)
        _transferToken(tokenA, msg.sender, address(this), amountADesired);
        _transferToken(tokenB, msg.sender, address(this), amountBDesired);

        // approve to the Router to withdraw the desired amounts of A & B tokens
        IERC20(tokenA).approve(address(uniswap), amountADesired);
        IERC20(tokenB).approve(address(uniswap), amountBDesired);

        // add liquidity
        uniswap.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            msg.sender,
            deadline
        );
    }

    // Adds liquidity to an ERC-20⇄WETH pool with ETH
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable {
        uniswap.addLiquidityETH(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            msg.sender,
            deadline
        );
    }

    // Removes liquidity from an ERC-20⇄ERC-20 pool
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external {
        uniswap.removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            msg.sender,
            deadline
        );
    }

    // Removes liquidity from an ERC-20⇄WETH pool and receive ETH
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external {
        uniswap.removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            msg.sender,
            deadline
        );
    }

    // Swaps an exact amount of input tokens for as many output tokens as possible, along the route determined by the path
    function swapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external {
        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountIn);

        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountIn);

        uniswap.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }

    // Receive an exact amount of output tokens for as few input tokens as possible, along the route determined by the path.
    function swapTokensForExactTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountInMin,
        uint256 amountOut,
        uint256 deadline
    ) external {
        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountInMin);

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountInMin);

        uniswap.swapTokensForExactTokens(
            amountOut,
            amountInMin,
            path,
            msg.sender,
            deadline
        );
    }

    // Swaps an exact amount of ETH for as many output tokens as possible, along the route determined by the path
    function swapExactETHforTokens(
        address tokenOut,
        uint256 amountOut,
        uint256 deadline
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = tokenOut;

        uniswap.swapExactETHForTokens{value: msg.value}(
            amountOut,
            path,
            msg.sender,
            deadline
        );
    }

    // Receive an exact amount of ETH for as few input tokens as possible, along the route determined by the path.
    function swapTokensForExactETH(
        address tokenIn,
        uint256 amountInMax,
        uint256 amountOut,
        uint256 deadline
    ) external {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = uniswap.WETH();

        // move 'amountInMin' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountInMax);

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountInMax);

        uniswap.swapTokensForExactETH(
            amountOut,
            amountInMax,
            path,
            msg.sender,
            deadline
        );
    }

    // Swaps an exact amount of tokens for as much ETH as possible, along the route determined by the path
    function swapExactTokensForETH(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external {
        // move 'amountIn' tokens from User to this Contract (User's approval is required before the transfer)
        _transferToken(tokenIn, msg.sender, address(this), amountIn);

        // an array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = uniswap.WETH();

        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(tokenIn).approve(address(uniswap), amountIn);

        // using 'now' for convenience, but should be sent from frontend!
        //uint256 deadline = block.timestamp + 15;

        // Calculates the amount out
        //uint256[] memory amountOutMin = uniswap.getAmountsOut(amountIn, path);

        // Swap Tokens for ETH
        uniswap.swapExactTokensForETH(
            amountIn, // The amount of input tokens to send
            amountOutMin, // The minimum amount of output tokens that must be received for the transaction not to revert (amountOutMin must be retrieved from an oracle of some kind)
            path, // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity
            msg.sender, // Recipient: Ether to be sent directly to the sender. If smart contract, it must be able to receive ETH!
            deadline // Unix timestamp after which the transaction will revert
        );
    }

    // Receive an exact amount of tokens for as little ETH as possible, along the route determined by the path. Leftover ETH, if any, is returned to msg.sender
    function swapETHForExactTokens(
        address tokenOut,
        uint256 amountOut,
        uint256 deadline
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = uniswap.WETH();
        path[1] = tokenOut;

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
