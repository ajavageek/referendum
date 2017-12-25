pragma solidity ^0.4.18;

contract VotingToken {

    string public symbol;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address _from, uint256 _value);

    function VotingToken(string _symbol, uint256 _totalSupply) public {
        symbol = _symbol;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[msg.sender] + balanceOf[_to];
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        assert(balanceOf[msg.sender] + balanceOf[_to] == previousBalances);
        return true;
    }

    function burn(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        balanceOf[_from] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
    
    function getBalanceOf(address _address) public view returns (uint256) {
        return balanceOf[_address];
    }
}
