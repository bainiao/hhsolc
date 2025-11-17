// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract BlindAuction {
    address public beneficiary;
    uint256 public endTime;
    uint256 public revealTime;
    address public highestBidder;
    uint256 public highestBid;
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
        uint256 reveal;
    }
    mapping(address => Bid) public bidders;
    modifier beforeEnd(){
        require(block.timestamp < endTime, "Auction has ended");
        _;
    }
    modifier auctionEnded(){
        require(block.timestamp >= endTime, "Auction has not ended");
        _;
    }
    event setWinner(address winner, uint256 amount);
    error alreadyRevealed();
    constructor(uint256 _endTime, address _beneficiary, uint256 _revealTime){
        beneficiary = _beneficiary;
        endTime = block.timestamp + _endTime;
        revealTime = block.timestamp + _revealTime;
    }
    function bid(bytes32 _blindedBid) payable beforeEnd public {
        bidders[msg.sender].deposit += msg.value;
        bidders[msg.sender].blindedBid = _blindedBid;
    }
    function reveal(uint256 _value) auctionEnded external {
        Bid storage bidder = bidders[msg.sender];
        require(bidder.blindedBid == keccak256(abi.encodePacked(_value)), "Invalid bid");
        require(bidder.reveal > 0, "Already revealed");
        if (block.timestamp >= revealTime) revert alreadyRevealed();
        bidder.reveal = _value;
        if(bidder.reveal > highestBid){
            highestBid = bidder.reveal;
            highestBidder = msg.sender;
        }
    }
    function finalDecision() external {
        require(block.timestamp >= revealTime, "Reveal time has not passed");
        require(highestBidder != address(0), "No bids");
        bidders[highestBidder].deposit -= bidders[highestBidder].reveal; 
        payable(beneficiary).transfer(highestBid);
        emit setWinner(highestBidder, highestBid);
    }
    function withdraw() external {
        require(block.timestamp >= revealTime, "Reveal time has not passed");
        require(bidders[msg.sender].deposit > 0, "No deposit");
        require(bidders[msg.sender].reveal == 0, "Already revealed");
        bidders[msg.sender].deposit = 0;
        bidders[msg.sender].reveal = 0;
        payable(msg.sender).transfer(bidders[msg.sender].deposit);
    }
}