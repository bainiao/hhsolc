// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "forge-std/console.sol";

contract Reentrant{
    mapping(address => bool) claimed;
    bool transient locked;
    modifier nonReentrant{
        console.log("locked:", locked);
        require(!locked, "Reentrancy attempt");
        locked = true;
        _;
        locked = false;
    }
    function claim() nonReentrant public {
        require(!claimed[msg.sender], "Already claimed");
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, ) = msg.sender.call{value:0}(payload);
        require(success, "claim failed");
        claimed[msg.sender] = true;
    }
}