//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library Balances{
    function move(mapping(address => uint256) storage balances, address from, address to, uint256 amount) internal {
        require(balances[from] >= amount, "Insufficient funds");
        require(amount > 0, "Amount must be greater than 0");
        balances[from] -= amount;
        balances[to] += amount;
    }
}
contract Token {
    mapping(address => uint256) balances;
    using Balances for *;
    mapping(address => mapping(address => uint256)) allowances;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    function transfer(address to, uint256 amount) external returns (bool) {
        balances.move(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) external{
        require(allowances[from][msg.sender] >= amount, "Insufficient allowance");
        allowances[from][msg.sender] -= amount;
        balances.move(from, to, amount);
        emit Transfer(from, to, amount);
    }
    function approval(address spender, uint256 amount) external {
        allowances[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
    }
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}