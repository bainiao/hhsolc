//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract SimpleAuction {
    address payable public beneficiary;
    uint256 public auctionEndTime;
    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint) public pendingReturns;
    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    error AuctionAlreadyEnded();
    error BidNotHighEnough(uint highestBid, uint bid);
    error AuctionNotYetEnded();
    constructor(uint biddingTime, address payable beneficiary_){
        beneficiary = beneficiary_;
        auctionEndTime = block.timestamp + biddingTime;
        ended = false;
    }
    
    function bid() external payable{
        if (block.timestamp > auctionEndTime) revert AuctionAlreadyEnded();
        uint256 totalBid = msg.value + pendingReturns[msg.sender];
        if (totalBid <= highestBid) revert BidNotHighEnough(highestBid, totalBid);
        if (highestBid != 0){
            pendingReturns[highestBidder] = highestBid;
        }
        pendingReturns[msg.sender] = 0;
        highestBidder = msg.sender;
        highestBid = totalBid;
        emit HighestBidIncreased(msg.sender, totalBid);
    }
    function withdraw() external returns (bool){
        require(ended, "withdraw after auction ended");
        uint amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;
        // payable(msg.sender).transfer(amount); // 2300 gas
        bool success = payable(msg.sender).send(amount); // 2300 gas
        // (success, _) = payable(msg.sender).call{value: amount, gas: 5000}("");
        if (!success) {
            pendingReturns[msg.sender] = amount;
            return false;
        }
        return true;
    }
    function auctionEnd() external {
        if (block.timestamp < auctionEndTime) revert AuctionNotYetEnded();
        ended = true;
        emit auctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
    function getRemainingTime() external view returns (uint256){
        return auctionEndTime - block.timestamp;
    }
}