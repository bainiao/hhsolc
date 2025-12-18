// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/console.sol";

contract DataStorage {
    string private data;

    function setData(string memory newData) public {
        data = newData;
    }

    function getData() public view returns (string memory) {
        return data;
    }
}

contract DataConsumer {
    address private dataStorageAddress;

    constructor(address _dataStorageAddress) {
        dataStorageAddress = _dataStorageAddress;
    }

    function getDataByABI() public returns (string memory) {
        // payload
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, bytes memory data) = dataStorageAddress.call(payload);
        require(success, "call function failed");
        
        // return data
        return abi.decode(data, (string));
    }

    function setDataByABI1(string calldata newData) public returns (bool success) {
        // playload
        bytes memory payload = abi.encodeWithSignature("setData(string)", newData);
        (success, ) = dataStorageAddress.call(payload);
    }

    function setDataByABI2(string calldata newData) public returns (bool success) {
        console.log("dataStorageAddress:", dataStorageAddress); // 打印地址
        require(dataStorageAddress != address(0), "dataStorageAddress is zero"); // 增加检查
        // selector
        bytes4 selector = bytes4(abi.encodePacked(keccak256("setData(string)")));
        // playload
        bytes memory payload = abi.encodeWithSelector(selector, newData);
        (success, ) = dataStorageAddress.call{gas:100000}(payload);
        require(success, "setDataByABI2: call failed"); 
    }

    function setDataByABI3(string calldata newData) public returns (bool success) {
        // playload
        bytes memory payload = abi.encodeCall(DataStorage(dataStorageAddress).setData, (newData));
        (success, ) = dataStorageAddress.call(payload);
    }
}
