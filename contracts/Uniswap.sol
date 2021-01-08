// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

interface IUniswap {
    // From uniswap-v2-periphery/contracts/UniswapV2Router02.sol
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    // From uniswap-v2-periphery/contracts/interfaces/IUniswapV2Router01.sol
    // Returns the address of wrapped ether
    function WETH() external pure returns (address);
}

interface IERC20 {
    // From openzeppelin-contracts/contracts/token/ERC20/IERC20.sol
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Goal: exchange tokens for ETH
// Market price should be calculated off-chain with Uniswap sdk
contract Uniswap {
    IUniswap uniswap;

    constructor(address _uniswap) {
        uniswap = IUniswap(_uniswap);
    }

    function swapTokensForETH(
        address token,
        uint256 amountIn, // amount of tokens to be provided
        uint256 amountOutMin, // min amount of ether we want
        uint256 deadline // deadline after which the trade is not valid anymore
    ) external {
        // move tokens from sending address to contract (needs approval before calling swapTokensForEth())
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        // Tokens we want to trade
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        IERC20(token).approve(address(uniswap), amountIn);
        uniswap.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender, // Recipient: Ether to be sent directly to the sender
            deadline
        );
    }
}
