// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.0;

contract Callee{
    uint256 public myValue;
    function setValue(uint256 _newValue) external{
        myValue = _newValue;
        emit ValueSet(msg.sender, _newValue);
    }
    function getContractAddress() public view returns (address) {
        return address(this);
    }
    event ValueSet(address indexed caller, uint256 indexed);
}

contract Caller{
    address private calleeAddress;
    uint256 private myValue;
    constructor(address _calleeAddress){
        calleeAddress = _calleeAddress;
    }
    function callSetValue(uint256 _newValue) public returns (bool success){
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", _newValue);
        (success, ) = calleeAddress.call(data);
        return success;
    }
    function callGetContractAddress() public view returns (address) {
        bytes memory data = abi.encodeWithSignature("getContractAddress()");
        // staticcall is used just for pure/view function.
        (bool success, bytes memory returnData) = payable(calleeAddress).staticcall(data);
        require(success, "Call failed");
        return abi.decode(returnData, (address));
    }
    function delegatecallSetValue(uint256 _newValue) public returns (bool success){
        bytes memory data = abi.encodeWithSignature("setValue(uint256)", _newValue);
        (success, ) = calleeAddress.delegatecall(data);
        return success;
    }
}