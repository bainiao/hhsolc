// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.17;

contract Destroy {
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    function killSelf(address receiver) external {
        require(msg.sender == owner);
        selfdestruct(payable(receiver));
    }
}