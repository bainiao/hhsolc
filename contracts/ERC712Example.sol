// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract ERC712Example {
    struct Order{
        address from;
        address to;
        uint256 amount;
    }
    bytes32 constant ORDER_TYPEHASH = keccak256("Order(address from,address to, uint256 amount)");
    bytes32 public DOMAIN_SEPARATOR;

    constructor(string memory name, string memory version) {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                block.chainid,
                address(this)
            )
        );
    }
    function _hashOrder(Order memory order) internal pure returns(bytes32){
        return keccak256(abi.encode(ORDER_TYPEHASH, order.from, order.to, order.amount));
    }
    function _hashTypeData(bytes32 structHash) internal view returns(bytes32){
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
    }
    function verify(Order calldata order, bytes memory signature) external view returns(bool){
        if (signature.length != 65) return false;
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly{
            r := mload(add(signature,32))
            s := mload(add(signature,64))
            v := byte(0, mload(add(signature,96)))
        }
        bytes32 structHash = _hashOrder(order);
        bytes32 digest = _hashTypeData(structHash);
        address signer = ecrecover(digest, v, r, s);
        return signer == order.from;
    }
}