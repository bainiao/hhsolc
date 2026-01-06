// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract BetMatchOutcome is ERC20, Ownable {
    address private usdcAddress;
    constructor() ERC20("BetMatchOutcome", "BMO") Ownable(msg.sender){
        
    }
    /// token exchange
    event USDCAddressChanged(address indexed newAddress);
    function setUSDC(address _usdcAddress) public onlyOwner {
        usdcAddress = _usdcAddress;
        emit USDCAddressChanged(_usdcAddress);
    }
    error USDCAddressNotSet();
    modifier USDCAddressNotZero() {
        require(usdcAddress != address(0), USDCAddressNotSet());
        _;
    }
    function buyTokenWithUsdc(uint256 amount) public USDCAddressNotZero {
        bool success = IERC20(usdcAddress).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        _mint(msg.sender, amount);
    }
    function buyUsdcWithToken(uint256 amount) public USDCAddressNotZero {
        _burn(msg.sender, amount);
        bool success = IERC20(usdcAddress).transfer(msg.sender, amount);
        require(success, "Transfer failed");
    }


}