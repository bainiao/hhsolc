// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {BaseProxy, Implementation} from "./BaseProxy.sol";

interface ILogic{
    function addCounter() external;
    function getCounter() external view returns(uint256);
}

contract BaseProxyTest is Test{
    BaseProxy bp;
    Implementation implementation;
    function setUp() public {
        implementation = new Implementation();
        bp = new BaseProxy(address(implementation));
    }
    function test_proxyCall() public {
        uint256 counterBefore = ILogic(address(bp)).getCounter();
        assertEq(counterBefore, 0);
        ILogic(address(bp)).addCounter();
        uint256 counterAfter = ILogic(address(bp)).getCounter();
        assertEq(counterAfter, 1);
    }
}