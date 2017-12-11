
//FOR TESTING PURPOSES ONLY. DO NOT USE IN PRODUCTION
//SAaS Smart Airdrop contract in development
//rev 0.3a
//11.12.2017

pragma solidity ^0.4.16;


library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

contract Owned {
    // The address of the account of the current owner
    address public owner;

    // The publiser is the inital owner
    function Owned() public {
        owner = msg.sender;
    }

    /**
     * Access is restricted to the current owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract airDrop {
    function verify(address _address, bytes32 _secret) public constant returns (bool _status);
}



/*
 * Pausable
 * Abstract contract that allows children to implement an
 * emergency stop mechanism.
 */

contract Pausable is Owned {
  bool public stopped;

  modifier stopInEmergency {
    if (stopped) {
      revert();
    }
    _;
  }
  
  modifier onlyInEmergency {
    if (!stopped) {
      revert();
    }
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

contract SMART1 is Pausable {
    using SafeMath for uint256;
    
    bool public locked;
    
    string public constant symbol = "SMT1";

    string public constant name = "Smart One";

    uint public constant decimals = 8;

    uint _totalSupply = 12000000 * 10 ** decimals;

    address owner;

    address airDropVerify;

    uint public airDropAmount;

    uint32 public airDropHeight;

    mapping (address => bool) public airDropMembers;

    mapping (address => uint) accounts;

    mapping (address => mapping (address => uint)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    modifier onlyUnlocked() {

      if (owner != msg.sender) {
        require(false == locked);
      }
      _;
    }

    function SmartOne() public {
        locked = true;
        owner = msg.sender;
        accounts[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public constant returns (uint __totalSupply) {
        return _totalSupply;
    }

    function balanceOf(address _account) public constant returns (uint balance) {
        return accounts[_account];
    }

    function allowance(address _account, address _spender) public constant returns (uint remaining) {
        return allowed[_account][_spender];
    }

    function transfer(address _to, uint _amount) public onlyUnlocked returns (bool success) {
        require(_amount > 0 && accounts[msg.sender] >= _amount);
        accounts[msg.sender] -= _amount;
        accounts[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public onlyUnlocked returns (bool success) {
        require(_amount > 0 && accounts[_from] >= _amount && allowed[_from][msg.sender] >= _amount);
        accounts[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        accounts[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }
    
    function lock() onlyOwner {
        locked = true;
    }

    function unlock() onlyOwner {
        locked = false;
    }

    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function SmartAirdrop(bytes32 _secret) public payable returns (bool _status) {
        // Checkout airdrop conditions and eligibility
        require(!airDropMembers[msg.sender] && airDrop(airDropVerify).verify(msg.sender, _secret) && airDropHeight > 0 && airDropAmount > 0 && accounts[owner] >= airDropAmount);
        // Transfer amount
        accounts[owner] -= airDropAmount;
        accounts[msg.sender] += airDropAmount;
        airDropMembers[msg.sender] = true;
        Transfer(owner, msg.sender, airDropAmount);
        airDropHeight--;
        // Return extra amount to sender
        if (msg.value > 0) {
            msg.sender.transfer(msg.value);
        }
        return true;
    }

    function airDropSetup(address _contract, uint32 _height, uint _units) public returns (bool _status) {
        require(msg.sender == owner);
        airDropVerify = _contract;
        airDropHeight = _height;
        airDropAmount = _units * 10 ** decimals;
        return true;
    }
    
        function withdrawFunds(uint _amount) public returns (bool _status) {
        require(msg.sender == owner && _amount > 0 && this.balance >= _amount);
        owner.transfer(_amount);
        return true;
    }
}
