// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract StringStorage1 {
    // uses only one storage slot, slot 0: 0x(len*2)00...(hex"hello")
    string public str = unicode"Hello中";
    function getString() public view returns (string memory) {
        return str;
    }
}

contract StringStorage2 {
    // uses two storage slots, slot 0: 0x20...(length 32), slot 1: 0x...(data)
    string public str = "This is a longer string that exceeds 31 bytes!";
    function getString() public view returns (string memory) {
        return str;
    }
}

contract EfficientString{
    bytes32 shortString = "abc";
    function getShortString() public view returns (string memory) {
        string memory value;
        assembly {
            // get slot 0
            let slot0value := sload(shortString.slot)
            // get the byte that holds the length info and divide it by 2 to get the length
            let len := div(shr(248, slot0value), 2)
            // get string, shift by 256 - (len*8) to get it to the most significant byte
            let str := shl(sub(256, mul(len, 8)), slot0value)
            // store length in memory
            mstore(0x80, len)
            // store string in memory
            mstore(0xa0, str)
            // make `value` reference 0x80 so that solidity does the returning for us
            value := 0x80
            // update free memory pointer
            mstore(0x40, 0xc0)
        }
        return value;
        // 0x0600000000000000000000000000000000000000000000000000000000616263
    }
    function storeShortString(string calldata value) external {
        assembly {
            if gt(value.length, 31){
                revert(0,0)
            }
            // put value after left shift 248, the value taks 8 bits
            let shiftedLen := shl(248, mul(value.length, 2))
            // calldataload(value.offset) = 0x1234000000xxxxxxxx...
            // shift right value.length*8, and put value, 0000xxx... is peeled.
            let str := shr(sub(256, mul(value.length, 8)), calldataload(value.offset))
            let toBeStored := or(shiftedLen, str)
            sstore(shortString.slot, toBeStored)
        }
    }
    function setString(string memory value) external{
        shortString =  bytes32(abi.encodePacked(value));
        // 0x6162630000000000000000000000000000000000000000000000000000000000
    }
    function getString() public view returns(bytes32){
        return shortString;
    }
}
