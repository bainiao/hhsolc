//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Purchase {
    address private buyer;
    address private seller;
    uint256 public price;
    bytes32 public itemName;
    enum orderStatus {
        nosell,
        onSelling,
        sold,
        shipping,
        finished
    }
    orderStatus public status;
    modifier condition(bool condition_){
        require(condition_);
        _;
    }
    error OnlyBuyer();
    error OnlySeller();
    error InvalidStatus();
    modifier onlyBuyer(){
        require(msg.sender == buyer, OnlyBuyer());
        _;
    }
    modifier onlySeller(){
        if (msg.sender != seller) revert OnlySeller();
        _;
    }
    modifier inState(orderStatus _status){
        if (status != _status) revert InvalidStatus();
        _;
    }
    event OrderCancelled(address seller, bytes32 itemName, uint256 timestamp);
    event ItemSold(address buyer, address seller, uint256 price, bytes32 itemName, uint256 timestamp);
    event ItemShipped(address seller, bytes32 itemName, uint256 timestamp);
    event TransactionFinished(address buyer, address seller, uint256 price, bytes32 itemName, uint256 timestamp);
    constructor(){}
    
    function sell(bytes32 _itemName, uint256 _price) payable public {
        require(status == orderStatus.nosell, "Order already exists");
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
        status = orderStatus.nosell;
        payable(seller).transfer(price); // refund
        emit OrderCancelled(seller, itemName, block.timestamp);
    }
    function buy() payable public {
        require(status == orderStatus.onSelling, "Order status wrong");
        require(msg.value == 2*price, "Deposit twice amount of price");
        buyer = msg.sender;
        status = orderStatus.sold;
        emit ItemSold(buyer, seller, price, itemName, block.timestamp);
    }
    function shipping() public {
        require(msg.sender == seller,"Only seller can shipping");
        require(status == orderStatus.sold, "Order status wrong");
        status = orderStatus.shipping;
        emit ItemShipped(seller, itemName, block.timestamp);
    }
    function finish() public {
        require(msg.sender == buyer,"Only buyer can finish");
        require(status == orderStatus.shipping, "Order status wrong");
        status = orderStatus.finished;
        payable(seller).transfer(2*price +price*95/100); // refund, seller get 95% of price, 5% for platform
        payable(buyer).transfer(price);
        emit TransactionFinished(buyer, seller, price, itemName, block.timestamp);
    }
}