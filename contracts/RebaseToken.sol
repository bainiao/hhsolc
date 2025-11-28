// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract RebaseToken is ERC20 {
    address[] private owners;
    uint256 private lastYearMint;
    uint256 private thisYearMint;
    uint256 private year;
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){
        lastYearMint = 100_000_000 * 10**18;
        _mint(msg.sender, lastYearMint);
        owners.push(msg.sender);
        year = getYear(block.timestamp);
    }
    function rebase() public {
        address[] memory temp = owners;
        for (uint256 i=0;i<temp.length;i++){
            _burn(temp[i], (balanceOf(temp[i])/totalSupply()) * (lastYearMint / 100));
        }
        lastYearMint = thisYearMint;
        thisYearMint = 0;
        year = getYear(block.timestamp);
    }
    function mint(address to, uint256 value) external returns(bool){
        require(to != address(0), "to address is 0");
        _mint(to, value);
        if (year == getYear(block.timestamp)){
            lastYearMint += value;
        }else{
            thisYearMint += value;
        }
        return true;
    }
    function getYear(uint256 timestamp) internal pure returns(uint256) {
        return 1970 + timestamp / 31557600;
    }
}