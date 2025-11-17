//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Purchase {
    address private buyer;
    address private seller;
    uint256 public price;
    bytes32 public itemName;
    enum orderStatus {
        none,
        onSelling,
        sold,
        shipping,
        finished
    }
    orderStatus public status;
    event TransactionFinished(address buyer, address seller, uint256 price, bytes32 itemName, uint256 timestamp);
    constructor(){}
    
    function sell(bytes32 _itemName, uint256 _price) payable public {
        require(status == orderStatus.none, "Order already exists");
        require(_price > 0, "Price must be greater than 0");
        require(msg.value == 2*_price, "Deposit twice amount of price");
        seller = msg.sender;
        itemName = _itemName;
        price = _price;
        status = orderStatus.onSelling;
    }
    function sellerCancel() public {
        require(msg.sender == seller,"Only seller can cancel");
        require(status == orderStatus.onSelling, "Order status wrong");
        status = orderStatus.none;
        payable(seller).transfer(price); // refund
    }
    function buy() payable public {
        require(status == orderStatus.onSelling, "Order status wrong");
        require(msg.value == 2*price, "Deposit twice amount of price");
        buyer = msg.sender;
        status = orderStatus.sold;
    }
    function shipping() public {
        require(msg.sender == seller,"Only seller can shipping");
        require(status == orderStatus.sold, "Order status wrong");
        status = orderStatus.shipping;
    }
    function finish() public {
        require(msg.sender == buyer,"Only buyer can finish");
        require(status == orderStatus.shipping, "Order status wrong");
        status = orderStatus.finished;
        payable(seller).transfer(3*price); // refund
        payable(buyer).transfer(price);
        emit TransactionFinished(buyer, seller, price, itemName, block.timestamp);
    }
}