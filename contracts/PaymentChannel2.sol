// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "./PaymentChannel.sol";

contract PaymentChannel2 is Freezable{
    struct Payment{
        address to;
        uint256 amount;
        uint256 expiration;
    }
    Payment[] private payments;
    uint256 private totalAmount;
    event IssuedPayment(address receiver, uint256 amount, uint256 _expiration);
    constructor(){}
    /// issue a payment to receiver
    function issuePayment(address receiver, uint256 amount, uint256 _expiration) isOwner payable external {
        totalAmount += amount;
        require(address(this).balance >= totalAmount, "deposit is not enough");
        payments.push();
        Payment storage p = payments[payments.length-1];
        p.to = receiver;
        p.amount = amount;
        p.expiration = block.timestamp + _expiration;
        emit IssuedPayment(receiver, amount, _expiration);
    }
}