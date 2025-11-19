//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Owned {
    address public owner;

    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Owner only");
        _;
    }
}

contract Freezable is Owned {
    bool private _frozen = false;
    modifier notFrozen(){
        require(!_frozen, "Contract is frozen");
        _;
    }
    function freeze() internal onlyOwner {
        _frozen = true;
    }
}

contract ReceivePays is Freezable {
    mapping(uint256 => bool) private usedNonce;
    constructor() payable{}
    function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external notFrozen {
        require(!usedNonce[nonce], "Nonce already used");
        require(amount <= address(this).balance, "Insufficient funds");
        require(verifySignature(msg.sender,amount, nonce, signature), "Invalid signature");
        usedNonce[nonce] = true;
        payable(msg.sender).transfer(amount);
    }
    function verifySignature(address signer, uint256 amount, uint256 nonce, bytes memory signature) internal pure returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(signer, amount, nonce)));
        return recoverSigner(message, signature) == signer;
    }
    function recoverSigner(bytes32 message, bytes memory signature) internal pure returns (address){
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }
    function splitSignature(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(signature.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
    function prefixed(bytes32 hash) internal pure returns (bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}