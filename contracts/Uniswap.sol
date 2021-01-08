// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

/*
 THIS CONTRACT!     0x96EdA813e373626834ff09482d63fa6aB8039F74
 Uniswap Router:    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
 DAI:               0xad6d458402f60fd3bd25163575031acdce07538d
 UNI:               0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
 WETH:              0xc778417e063141139fce010982780140aa0cd5ab
*/
interface IUniswap {
    // From uniswap-v2-periphery/contracts/UniswapV2Router02.sol
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

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

    // constructor(address _uniswap) {
    //     uniswap = IUniswap(_uniswap);
    // }

    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant DAI_ADDRESS = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    constructor() {
        uniswap = IUniswap(UNISWAP_ROUTER_ADDRESS);
    }
    

    // Swaps an exact amount of tokens for as much ETH as possible, along the route determined by the path
    function swapTokensForETH(
        //address token,
        uint256 amountIn,
        uint256 amountOutMin
        //uint256 deadline
    ) external {
        address token = DAI_ADDRESS;
        uint deadline = block.timestamp + 15; // using 'now' for convenience, but should be sent from frontend!
        // needs approval before calling swapTokensForEth())
        //require(IERC20(token).approve(address(uniswap), (amountIn + 10000)), 'Uniswap approval failed');
        // move 'amountIn' tokens from msg.sender to this contract 
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
        // An array of token addresses (tokens we want to trade). path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity.
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = uniswap.WETH();
        // approve to the Router to withdraw this 'amountIn' tokens
        IERC20(token).approve(address(uniswap), amountIn);
        // Swap Tokens for ETH
        uniswap.swapExactTokensForETH(
            amountIn, // The amount of input tokens to send.
            amountOutMin, // The minimum amount of output tokens that must be received for the transaction not to revert (amountOutMin must be retrieved from an oracle of some kind)
            path, // An array of token addresses. path.length must be >= 2. Pools for each consecutive pair of addresses must exist and have liquidity
            msg.sender, // Recipient: Ether to be sent directly to the sender. If smart contract, it must be able to receive ETH!
            deadline // Unix timestamp after which the transaction will revert
        );
    }

    // Receive an exact amount of tokens for as little ETH as possible, along the route determined by the path. Leftover ETH, if any, is returned to msg.sender
    function swapETHForTokens(
        //address token,
        uint256 amountOut
        //uint256 deadline
    ) external payable {
        address token = DAI_ADDRESS;
        uint deadline = block.timestamp + 15; // using 'now' for convenience, but should be sent from frontend!
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

    // important to receive ETH
    receive() payable external {}
}

/* Sample input for swapExactTokensForETH:
token:		    0xad6d458402f60fd3bd25163575031acdce07538d
amount: 		2807740571120975129
amountOutMin:	2807740571120975
deadline:		1610214892
*/

/* Sample input for swapETHForExactTokens:
token:		    0xad6d458402f60fd3bd25163575031acdce07538d
amountOut: 		1000000000000000000
deadline:		1610214892
msg.value       
*/
