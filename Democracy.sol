// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity '0.8.17';

contract Democracy {

    string public topic;
    string[] public choices;
    uint public numChoices;
    uint[] public results;

    bool public started  = false;
    bool public ended = false;

    uint256 totalVotes;

    address payable owner;

    mapping(address => int256) public voted;
    address payable[] voters;

    uint256 numVoters;

    modifier start() {
        require(msg.sender == owner);
        require(started == false);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: You are not the owner, Bye.");
        _;
    }

    modifier onlyRegistered() {
        require(voted[msg.sender] == -1, "Unregistered voter. Cya.");
        require(started == true);
        require(ended == false);
        _;
    }

    constructor() payable {
        owner = payable(msg.sender);
    }

    receive() external payable onlyOwner {}

    function beginVote(string memory _question,
        string[] memory _choices,
        address payable[] memory _voters) public start {
        totalVotes = 0;
        topic = _question;
        numChoices = _choices.length;
        choices = _choices;
        numVoters = _voters.length;
        voters = _voters;
        // init results to zero
        for (uint i = 0; i < numChoices; i++) {
            results.push(0);
        }
        // init voted
        for (uint256 i = 0; i < numVoters; i++) {
            voted[_voters[i]] = -1;
        }
        // commence voting
        started = true;
    }

    function sendBallot(uint256 _ballot) public onlyRegistered {
        results[_ballot]++;
        totalVotes++;
        voted[msg.sender] = 1;
        if (totalVotes == numVoters) {
            ended = true;
        }
    }
}
