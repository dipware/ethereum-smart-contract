// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity '0.8.7';

contract Democracy {
    struct Question {
        string text;
        string[] choices;
        uint256[] results;
    }

    Question ballot;

    bool locked = false;

    uint256 totalVotes;
    // string question;
    // string[] questions;
    // string[] choices;
    // uint[] results;
    // mapping(uint => string)[] choices;
    // mapping(uint => mapping(uint256 => uint256)) results;

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

    modifier whenComplete() {
        require(locked == true, "Voting in progress. Results unavailable.");
        _;
    }

    constructor(
        string memory _question,
        string[] memory _choices,
        address payable[] memory _voters
    ) payable {
        totalVotes = 0;
        numVoters = 0;
        owner = payable(msg.sender);
        ballot = Question(_question, _choices, new uint256[](_choices.length));
        // ballot.text = _question;
        // ballot.choices = _choices;
        numVoters = _voters.length;
        voters = _voters;
        for (uint256 i = 0; i < numVoters; i++) {
            voted[_voters[i]] = -1;
        }
    }

    receive() external payable onlyOwner {}

    function lock() private {
        locked = true;
    }

    function getResults() public view whenComplete returns (uint256[] memory) {
        return ballot.results;
    }

    function getTopic() public view onlyRegistered returns (string memory) {
        return ballot.text;
    }

    function getChoices() public view onlyRegistered returns (string[] memory) {
        return ballot.choices;
    }

    function sendBallot(uint256 _ballot) public onlyRegistered {
        ballot.results[_ballot]++;
        totalVotes++;
        voted[msg.sender] = 1;
        if (totalVotes == numVoters) {
            locked = true;
        }
    }

    // function registerVoters(address payable[] memory _voters) public onlyOwner {
    //     numVoters = _voters.length;
    //     voters = _voters;
    //     for (uint256 i = 0; i < numVoters; i++) {
    //         voted[_voters[i]] = -1;
    //     }
    // }

    // function fundVoters(uint256 _gasEstimate) public onlyOwner {
    //     require(numVoters > 0);
    //     for (uint256 i = 0; i < numVoters; i++) {
    //         voters[i].transfer(_gasEstimate);
    //     }
    // }
}
