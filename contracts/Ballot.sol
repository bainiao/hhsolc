//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

contract Ballot{
    struct Voter{
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }
    struct Proposal{
        bytes32 name;
        uint voteCount;
    }
    address public chairPerson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    uint public votingStartTime;
    uint public votingEndTime;
    constructor(bytes32[] memory proposalNames,uint startTime, uint duration){
        chairPerson = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++){
            proposals.push(Proposal({name:proposalNames[i],voteCount:0}));
        }
        votingStartTime = startTime;
        votingEndTime = startTime + duration;
    }
    modifier beforeVoting(){
        require(block.timestamp<votingStartTime, "vote has started.");
        _;
    }
    modifier duringVoting(){
        require(block.timestamp>=votingStartTime&&block.timestamp<votingEndTime, "vote is not active");
        _;
    }
    modifier afterVoting(){
        require(block.timestamp>votingEndTime, "vote is not end.");
        _;
    }
    function giveRightToVote(address voter) external beforeVoting {
        require(msg.sender == chairPerson, "you don't have right to asign vote right.");
        require(voter != address(0), "invalid voter address");
        require(!voters[voter].voted, "you already voted.");
        require(voters[voter].weight == 0, "voter already have vote right.");
        voters[voter].weight = 1;
    }
    function delegate(address to) external duringVoting {
        Voter storage sender = voters[msg.sender];
        require(sender.weight > 0, "you don't have right to vote.");
        require(!sender.voted, "you already voted.");
        require(to != msg.sender, "self-delegation is not allowed.");
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "found loop in delegation.");
        }
        Voter storage delegate_ = voters[to];
        require(delegate_.weight > 0, "delegate account have no right to vote");
        sender.voted = true;
        sender.delegate = to;
        if (delegate_.voted){
            proposals[delegate_.vote].voteCount += sender.weight;
        }else{
            delegate_.weight += sender.weight;
        }
    }
    function vote(uint proposal) external duringVoting(){
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you already voted.");
        require(sender.weight > 0, "you don't have right to vote.");
        require(proposal < proposals.length, "invalid proposal index");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }
    function winningProposal() public view afterVoting returns (uint[] memory){
        uint winningVoteCount;
        uint tieCount;
        for (uint p; p< proposals.length; p++){
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = p;
                tieCount = 0;
            }else if (proposals[p].voteCount == winningVoteCount) {
                tieCount += 1;
            }
        }
        uint[] memory winner = new uint[](tieCount);
        uint i;
        for (uint p;p<proposals.length;){
            if (proposals[p].voteCount == winningVoteCount){
                winner[i] = p;
                unchecked{
                    ++i;
                }
            }
            unchecked {
                ++p;
            }
        }
        return winner;
    }
    function winnerName() external view afterVoting returns (bytes32[] memory){
        uint[] memory winner_ = winningProposal();
        bytes32[] memory winner = new bytes32[](winner_.length);
        for (uint i; i < winner_.length; ){
            winner[i] = proposals[winner_[i]].name;
            unchecked {
                ++i;
            }
        }
        return winner;
    }
}