// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FomoERC20 is ERC20 {
    address public uAddress;
    address private owner;
    constructor(address _uaddress) ERC20("FomoToken", "FOMO") {
        owner = msg.sender;
        uAddress = _uaddress;
    }
    event BoughtFomo(address indexed buyer, uint256 indexed amount);
    error ZeroValue();
    error TransferFailed();
    function buyFomo(uint256 value) public returns (bool) {
        require(value > 0, ZeroValue());
        bool suc = IERC20(uAddress).transferFrom(msg.sender, address(this), value);
        require(suc, TransferFailed());
        _mint(msg.sender, value);
        emit BoughtFomo(msg.sender, value);
        return true;
    }
    error InsufficientFomoBalance();
    function sellFomo(uint256 amount) public returns (bool) {
        require(amount > 0, ZeroValue());
        require(balanceOf(msg.sender) >= amount, InsufficientFomoBalance());
        _burn(msg.sender, amount);
        bool suc = IERC20(uAddress).transferFrom(address(this), msg.sender, amount);
        require(suc, TransferFailed());
        return true;
    }
}
