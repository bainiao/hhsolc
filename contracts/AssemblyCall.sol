// SPDX-License-Identifier:GPL-3.0

pragma solidity ^0.8.20;

/// 30570
contract Sol {
    function set(address addr, uint256 num) external {
        Callme(addr).setNum(num);
    }
}
/// 30350
contract Assembly {
    function set(address addr, uint256 num) external {
        assembly {
            mstore(0x00, hex"cd16ecbf")
            mstore(0x04, num)
            if iszero(extcodesize(addr)) {
                revert(0x00, 0x00) // revert if address has no code deployed to it
            }
            let success := call(gas(), addr, 0x00, 0x00, 0x24, 0x00, 0x00)
            if iszero(success) {
                revert(0x00, 0x00)
            }
        }
    }
}
contract Callme {
    uint256 num = 1;
    function setNum(uint256 a) external {
        num = a;
    }
}