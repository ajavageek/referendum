pragma solidity ^0.4.18;

import "./VotingToken.sol";

contract ReferendumContract {
    
    Referendum private referendum;
    address private tokenAddress;
    
    struct Referendum {
        string question;
        address owner;
        uint256 votesLimit;
        bool open;
        CastVotes votes;
    }

    struct CastVotes {
        uint256 yesCount;
        uint256 noCount;
        uint256 blankCount;
    }

    enum Answer { Yes, No, Blank }
    
    event Vote(address indexed _from, Answer _answer, uint256 _count);
    event Finish(address _referendum, string _question, uint256 _yesCount, uint256 _noCount, uint256 blankCount);
    
    function ReferendumContract(string _question, uint256 _votesLimit, address _tokenAddress) public {
        tokenAddress = _tokenAddress;
        referendum = Referendum(_question, msg.sender, _votesLimit, true, CastVotes(0, 0, 0));
    }
    
    function castVote(Answer _answer) public {
        castVotes(_answer, 1);
    }

    function castVotes(Answer _answer, uint256 _count) public {
        require(referendum.open);                              // <1>
        VotingToken tokenContract = VotingToken(tokenAddress); // <2>
        tokenContract.burn(msg.sender, _count);                // <3>
        handleVotes(_answer, _count);                          // <4>
        Vote(msg.sender, _answer, _count);                     // <5>
        if (hasAllVotes()) {
            close();
        }
    }

    function hasAllVotes() private view returns (bool) {
        uint256 votesCount = referendum.votes.yesCount + referendum.votes.noCount + referendum.votes.blankCount;
        return referendum.votesLimit == votesCount;
    }

    function handleVotes(Answer _answer, uint256 _count) private {
        if (_answer == Answer.Yes) {
            referendum.votes.yesCount += _count;
        } else if(_answer == Answer.No) {
            referendum.votes.noCount += _count;
        } else {
            referendum.votes.blankCount += _count;
        }
    }
    
    function isOpen() public view returns (bool) {
        return referendum.open;
    }
    
    function getQuestion() public view returns (string) {
        return referendum.question;
    }
    
    function close() public returns (uint256 yesCount, uint256 noCount, uint256 blankCount) {
        require(msg.sender == referendum.owner);
        referendum.open = false;
        Finish(this, referendum.question, referendum.votes.yesCount, referendum.votes.noCount, referendum.votes.blankCount);
        return getResults();
    }
    
    function getResults() public view returns (uint256 yesCount, uint256 noCount, uint256 blankCount) {
        return (referendum.votes.yesCount, referendum.votes.noCount, referendum.votes.blankCount);
    }
}
