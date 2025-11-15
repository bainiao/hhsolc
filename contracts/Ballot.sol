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

    constructor(bytes32[] memory proposalNames){
        chairPerson = msg.sender;
        for (uint i = 0; i < proposalNames.length; i++){
            proposals.push(Proposal({name:proposalNames[i],voteCount:0}));
        }
    }
    function giveRightToVote(address voter) external {
        require(msg.sender == chairPerson, "you don't have right to asign vote right.");
        require(voter != address(0), "invalid voter address");
        require(!voters[voter].voted, "you already voted.");
        require(voters[voter].weight == 0, "voter already have vote right.");
        voters[voter].weight = 1;
    }
    function delegate(address to) external{
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
    function vote(uint proposal) external{
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "you already voted.");
        require(sender.weight > 0, "you don't have right to vote.");
        require(proposal < proposals.length, "invalid proposal index");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }
    function winningProposal() public view returns (uint winningProposal_){
        uint winningVoteCount = 0;
        for (uint p = 0; p< proposals.length; p++){
            if (proposals[p].voteCount > winningVoteCount) {
                winningProposal_ = p;
                winningVoteCount = proposals[p].voteCount;
            }
        }
    }
    function winnerName() external view returns (bytes32){
        return proposals[winningProposal()].name;
    }
}