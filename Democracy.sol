// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity '0.8.7';

contract Democracy {
    struct Question {
        string text;
        string[] choices;
        uint256[] results;
    }
    Question[] ballot;
    bool locked = false;

    uint256 totalVotes;
    string[] questions;
    mapping(uint256 => mapping(uint256 => uint256)) results;

    address payable owner;

    mapping(address => int256) public voted;
    address payable[] voters;

    uint256 numVoters;

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: You are not the owner, Bye.");
        _;
    }

    modifier onlyRegistered() {
        require(voted[msg.sender] == -1, "Unregistered voter. Cya.");
        _;
    }

    constructor() {
        totalVotes = 0;
        numVoters = 0;
        owner = payable(msg.sender);
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    receive() external payable onlyOwner {}

    function lock() private {
        locked = true;
    }

    function getResults() public view returns (int256) {
        return results;
    }
    function getResults2(string calldata question, int256 choice) public view returns (int256) {
        return results2[question][choice];
    }

    function getTotalVotes() public view returns (int256) {
        return totalVotes;
    }

    function sendBallot(int256 ballot) public onlyRegistered {
        results += ballot;
        totalVotes++;
        votes[msg.sender] = ballot;
    }

    function registerVoters(address payable[] memory _voters) public onlyOwner {
        numVoters = _voters.length;
        voters = _voters;
        for (uint256 i = 0; i < numVoters; i++) {
            // init as negative -1 to signify null
            votes[_voters[i]] = -1;
        }
    }

    function fundVoters(uint256 _gasEstimate) public onlyOwner {
        require(numVoters > 0);
        for (uint256 i = 0; i < numVoters; i++) {
            voters[i].transfer(_gasEstimate);
        }
    }
}
