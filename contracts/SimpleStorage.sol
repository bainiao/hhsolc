//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleStorage{
    uint storeData;
    function set(uint x) public {
        storeData = x;
    }
    function get() public view returns (uint){
        return storeData;
    }
}