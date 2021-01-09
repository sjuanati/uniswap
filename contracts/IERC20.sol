// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

interface IERC20 {
    // From openzeppelin-contracts/contracts/token/ERC20/IERC20.sol
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}
