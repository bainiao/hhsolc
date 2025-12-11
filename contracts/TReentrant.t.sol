// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {Reentrant} from "./TReentrant.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

contract ReentrantTest is Test{
    Reentrant reen;
    function setUp() public{
        reen = new Reentrant();
    }
    // function getData() public{
    // }

    function test_Claim() public{
        vm.expectRevert();
        reen.claim();
    }
    receive() external payable{
        reen.claim();
    }
    fallback() external payable{
        console.log("enter fallback, and call claim again...");
        reen.claim();
    }
}