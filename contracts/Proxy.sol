// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Logic {
    address public logicAddress;
    uint256 public count;
    address private owner;
    function incrementCounter() public {
        count += 1;
    }
    function getCount() public view returns(uint256){
        return count;
    }
}

contract Proxy {
    address public logicAddress;
    uint256 public count;
    address private owner;
    error NoRight();
    error UserOnly();
    constructor(address _logicAddress){
        owner = msg.sender;
        logicAddress = _logicAddress;
    }
    function updataLogicAddress(address _logicAddress) external {
        require(msg.sender == owner, NoRight());
        logicAddress = _logicAddress;
    }
    fallback() external payable{
        require(msg.sender != owner, UserOnly());
        _fallback(logicAddress);
    }
    receive() external payable{
        _fallback(logicAddress);
    }
    function _fallback(address logic) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0,0, calldatasize())
            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), logic, 0, calldatasize(),0,0)
            // Copy the returned data.
            returndatacopy(0,0, returndatasize())
            switch result
            // delegatecall returns 0 on error
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }
}