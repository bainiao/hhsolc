// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Owned {
    address internal owner;
    constructor(){
        owner = msg.sender;
    }
    error notOwner();
    modifier isOwner (){
        require(msg.sender == owner, notOwner());
        _;
    }
}

contract Freezable is Owned {
    bool private frozen = false;
    error contractFrozen();
    modifier noFrozen(){
        require(!frozen, contractFrozen());
        _;
    }
    function freeze() isOwner public {
        frozen = true;
    }
}

contract PaymentChannel is Freezable{
    uint256 private nonce;
    mapping(uint256 => bool) usedNonce;
    error NonceUsed();
    uint256 private expiration;
    modifier noUsedNonce(uint256 _nonce){
        require(!usedNonce[_nonce],NonceUsed());
        _;
    }
    event IssuedPayment(address receiver, uint256 amount, uint256 _expiration);
    constructor(){}
    /// issue a payment to receiver
    function issuePayment(address receiver, uint256 amount, uint256 _expiration) payable external returns (bytes32){
        require(address(this).balance >= amount, "deposit is not enough");
        bytes32 payMsg = keccak256(abi.encodePacked(address(this), receiver, amount, nonce));
        nonce += 1;
        expiration = block.timestamp + _expiration;
        emit IssuedPayment(receiver, amount, expiration);
        return payMsg;
    }
    function claimPayment(uint256 amount, uint256 _nonce, bytes memory signature) noFrozen external{
        require(!usedNonce[_nonce], "nonce used");
        usedNonce[_nonce] = true;
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, _nonce, this)));
        require(recoverSigner(message, signature) == owner);
    }
    function prefixed(bytes32 hash) pure internal returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function recoverSigner(bytes32 message, bytes memory signature) internal pure returns (address){
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s){
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig,96)))
        }
        return (v, r, s);
    }
}