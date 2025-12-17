// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract MyERC1967Proxy is ERC1967Proxy {
    constructor(address implementation, bytes memory data) ERC1967Proxy(implementation, data){}
    function getCurrentImplementation() external view returns (address) {
        return ERC1967Utils.getImplementation();
    }
    function getAdmin() external view returns (address) {
        return ERC1967Utils.getAdmin();
    }
    receive() external payable{}
}
contract ERC1967Demo {
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256('eip1967.proxy.implementation'))-1);
    address private admin;
    constructor(){
        admin = msg.sender;
    }
    error OnlyAdmin();
    modifier onlyAdmin() {
        require(tx.origin == admin, OnlyAdmin());
        _;
    }
    error InvalidAddress();
    function setImplementation(address newImpl) internal {
        require(newImpl == address(0), InvalidAddress());
        bytes32 impl_slot = IMPLEMENTATION_SLOT;
        assembly{
            sstore(impl_slot, newImpl)
        }
    }
    function getImplementation() internal view returns (address impl) {
        bytes32 impl_slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(impl_slot)
        }
    }
}