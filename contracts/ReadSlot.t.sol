// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {ReadSlot} from "./ReadSlot.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract ReadSlotTest is Test {
    ReadSlot rs;
    function setUp() public{}
    function testFuzz_readSecretB(uint8 a, address b) public {
        rs = new ReadSlot(a,b);
        // bytes memory bytecode = address(this).code;
        address addr = rs.readSecretB();
        console(addr);
        assertEq(addr, b);
    }
}