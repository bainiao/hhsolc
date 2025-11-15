//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Coin {
    address public minter;
    mapping(address => uint256) public balances;
    event Sent(address from, address to, uint256 amount);
    constructor(){
        minter = msg.sender;
    }
    function mint(address receiver, uint256 amount) public {
        require(msg.sender == minter, "you have no right to mint.");
        balances[receiver] += amount;
    }
    error InsufficientBalance(uint requested, uint available);
    function send(address to, uint256 amount) public {
        require(balances[msg.sender]>=amount, InsufficientBalance(amount, balances[msg.sender]));
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Sent(msg.sender, to, amount);
    }
    function balanceOf(address account) view public returns (uint256) {
        return balances[account];
    }
    
}