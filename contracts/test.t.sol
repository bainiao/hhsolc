// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {DataConsumer, DataStorage} from "./test.sol";
import {Test} from "forge-std/Test.sol";

contract DataConsumerTest is Test {
    DataConsumer dc;
    DataStorage ds;

    function setUp() public {
        ds = new DataStorage();
        dc = new DataConsumer(address(ds));
    }

    function testFuzz_setDataByABI1(string calldata str) public {
        dc.setDataByABI1(str);
        string memory data = ds.getData();
        assertEq(str, data);
    }
    function testFuzz_setDataByABI2(string calldata str) public {
        dc.setDataByABI2(str);
        string memory data = ds.getData();
        assertEq(str, data);
    }
    function testFuzz_setDataByABI3(string calldata str) public {
        dc.setDataByABI3(str);
        string memory data = ds.getData();
        assertEq(data, str);
    }
}