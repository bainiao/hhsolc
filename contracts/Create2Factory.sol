// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.12;

contract Child {
    string public message;
    constructor(string memory _message){
        message = _message;
    }
    function setMessage(string calldata _message) public{
        message = _message;
    }
}

contract Create2Factory {
    function deployContract(bytes32 _salt, string calldata _message) public returns(address) {
        // bytes memory bytecode = type(Child).creationCode;
        // bytes memory constructorArgs = abi.encodePacked(_message);
        // bytes memory fullyBytecode = abi.encodePacked(bytecode, constructorArgs);
        address deployedAddress;
        // assembly {
        //     deployedAddress := create2(0, add(fullyBytecode, 0x20), mload(fullyBytecode), _salt)
        // }
        // require(deployedAddress != address(0), "Deployment failed");
        Child child = new Child{salt: _salt}(_message);
        deployedAddress = address(child);
        return deployedAddress;
    }
    function computeAddress(bytes32 _salt, string calldata _message) public view returns(address){
        bytes memory bytecode = type(Child).creationCode;
        // bytes memory constructionArgs = abi.encodePacked(_message);
        // bytes memory fullBytecode = abi.encodePacked(bytecode, constructionArgs);
        // bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(fullBytecode)));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        // hash：64位16进制数， address：40位16进制数，先转uint256,然后用uint160低位截断，得到后20位byte，再转address
        return address(uint160(uint256(hash)));
        // return address(hash[12:]);
    }
}