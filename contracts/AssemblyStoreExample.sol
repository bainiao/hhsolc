// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract AssemblyStoreExample{
    uint256 public num;
    function setNum(uint256 _num) external {
        assembly {
            sstore(num.slot, _num)
        }
    }
    function getNum() external view returns(uint256){
        uint256 n;
        assembly {
            n := sload(num.slot)
        }
        return n;
    }

    mapping(address => uint256) public balances;
    function setBalance(address user, uint256 amount) external {
        assembly {
            //计算mapping的存储槽位置
            mstore(0x0, user)
            mstore(0x20, balances.slot)
            let slot := keccak256(0x0, 0x40)
            sstore(slot, amount)
        }
    }
    function getBalance(address user) external view returns(uint256){
        uint256 bal;
        assembly {
            //计算mapping的存储槽位置
            mstore(0x0, user)
            mstore(0x20, balances.slot)
            let slot := keccak256(0x0, 0x40)
            bal := sload(slot)
        }
        return bal;
    }
    uint128 private data1;  // high 128 bits
    uint128 private data2;  // low 128 bits
    function setData(uint128 d1, uint128 d2) external {
        assembly {
            let packedData := or(shl(128, d2), d1)
            sstore(data1.slot, packedData)
        }
    }
    function getData() external view returns(uint128, uint128){
        uint128 d1;
        uint128 d2;
        assembly {
            let packedData := sload(data1.slot)
            d1 := and(packedData, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            d2 := shr(128, packedData)
        }
        return (d1, d2);
    }
}