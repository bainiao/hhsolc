//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "forge-std/console.sol";

contract Secret {
    struct SecretStruct {
        uint16 a;
        address b;
    }

    SecretStruct private secret;

    constructor(uint16 a, address b) {
        secret = SecretStruct(a, b);
        console.log(a,b);
    }
}

contract ReadSlot is Secret {
    constructor(uint16 a, address b) Secret(a, b) {}

    function readSecretB() public view returns (address) {
        address addr;
        assembly{
            let slot0 := sload(0)
            addr := shr(16,slot0)
        }
        return addr;
    }
}