// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {AssemblyStoreExample} from "./AssemblyStoreExample.sol";

contract AssemblyStoreExampleTest is Test {
    AssemblyStoreExample ase;
    function setUp() public {
        ase = new AssemblyStoreExample();
    }
    function test_assemblyStoreExample() public {
        ase.setNum(0x12345678);
        uint256 val = ase.getNum();
        console.log(uint256(val));
        assertEq(val, 0x12345678);
    }
    function test_balance() public {
        ase.setBalance(msg.sender, 11);
        uint256 bal = ase.getBalance(msg.sender);
        console.log(uint256(bal));
        assertEq(11, bal);
    }
    function test_getData() public{
        ase.setData(12,13);
        (uint128 a, uint128 b) = ase.getData();
        console.log("a:", a, "b:", b);
        assertEq(a, 12);
        assertEq(b, 13);
    }
}