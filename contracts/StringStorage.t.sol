// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {StringStorage1, StringStorage2, EfficientString} from "./StringStorage.sol";

contract StingStorageTest is Test{
    StringStorage1 ss1;
    StringStorage2 ss2;
    EfficientString es;
    function setUp() public{
        ss1 = new StringStorage1();
        ss2 = new StringStorage2();
        es = new EfficientString();
    }
    function test_stringStorage1() public{
        ss1.getString();
        bytes32 data = vm.load(address(ss1), 0);
        emit log_named_bytes32("data", data);
    }
    function test_stringStorage2() public{
        ss2.getString();
        bytes32 length = vm.load(address(ss2), 0);
        emit log_named_bytes32("length", length);
        bytes32 data = vm.load(address(ss2), keccak256(abi.encode(0)));
        emit log_named_bytes32("data", data);
    }
    function test_shortString() public {
        es.storeShortString("nihao");
        string memory str = es.getShortString();
        assertEq(str, "nihao");
    }
}