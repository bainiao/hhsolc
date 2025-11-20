// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Coin.sol";

contract Frozeable{
    bool private _frozen;
    modifier notFrozen(){
        require(!_frozen, "Contract is frozen");
        _;
    }
    function freeze() public{
        _frozen = true;
    }
}

contract SinglePaymentChannel is Frozeable{
    address payable public sender;
    address payable public receiver;
    uint256 public expiration;
    constructor(address payable _receiver, uint256 duration){
        sender = payable(msg.sender);
        receiver = _receiver;
        expiration = block.timestamp + duration;
    }
    function close(uint256 amount, bytes memory signature) public notFrozen{
        require(msg.sender == receiver, "Only receiver");
        require(block.timestamp < expiration, "Channel expired");
        require(amount <= address(this).balance, "Insufficient balance");
        require(isValidSignature(amount, signature), "Invalid signature");
        receiver.transfer(amount);
        freeze();
        sender.transfer(address(this).balance);
    }
    function isValidSignature(uint256 amount, bytes memory signature) private view returns(bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(address(this), amount)));
        return recoverSigner(message, signature) == sender;
    }
    function prefixed(bytes32 hash) private pure returns(bytes32){
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function recoverSigner(bytes32 message, bytes memory signature) private pure returns(address){
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }
    function splitSignature(bytes memory signature) private pure returns(bytes32 r, bytes32 s, uint8 v){
        require(signature.length == 65, "Invalid signature");
        assembly{
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        return (r, s, v);
    }
}