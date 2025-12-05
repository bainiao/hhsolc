// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FomoERC20 is ERC20 {
    address public uAddress;
    address private owner;
    constructor(address _uaddress) ERC20("FomoToken", "FOMO") {
        owner = msg.sender;
        uAddress = _uaddress;
    }
}
