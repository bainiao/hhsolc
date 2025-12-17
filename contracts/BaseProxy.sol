// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Implementation{
    address public implementation;
    uint256 private counter;
    function addCounter() public {
        counter += 1;
    }
    function getCounter() public view returns(uint256){
        return counter;
    }
}

contract BaseProxy{
    address private implementation;
    constructor(address _implementation){
        implementation = _implementation;
    }
    fallback() external payable{
        _fallback();
    }
    receive() external payable{
        _fallback();
    }
    function _fallback() internal{
        assembly{
            let target := sload(implementation.slot)
            calldatacopy(0,0,calldatasize())
            let suc := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch suc
            case 0{
                revert(0, returndatasize())
            }
            case 1{
                return(0, returndatasize())
            }
        }
    }
}