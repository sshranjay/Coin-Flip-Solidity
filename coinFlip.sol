pragma solidity ^0.5.0;

contract coinFlip {
    event wonBet (address gamblerAddress, uint betAmount);
    
    struct Gambler {
        bool isOpenBet;
        uint balance;
        uint bet;
    }
    
    mapping (address => Gambler) gambling;
    address[] public openGamblerAddress;         //stores the addresses of all the users placing bets

    constructor() public {
        gambling[msg.sender].balance = 100;     //initialize the account balance to 100
    }
    
    function placeBet(uint _betAmount, uint _bet) public {
        require(gambling[msg.sender].isOpenBet == false, "You have an existing open bet");
        require(_bet == 0 || _bet == 1, "Enter 0 or 1");
        require(_betAmount <= gambling[msg.sender].balance, "Bet amount must be less than your remaining balance");
        gambling[msg.sender].balance = gambling[msg.sender].balance - _betAmount;
        gambling[msg.sender].bet = _bet;
        gambling[msg.sender].isOpenBet = true;
        openGamblerAddress.push(msg.sender);            
    }

    function rewardBets() public {
        bytes32 vrfNumber = vrf();          //VRF function call
        uint vrfInt = uint(vrfNumber);
        uint _vrf;
        if(vrfInt % 2 == 0) {               //if random number generated is even, the bet amount is heads else it is tails
            _vrf = 0;
        }
        else {
            _vrf = 1;
        }
        for(uint i=0; i<openGamblerAddress.length; i++) {
            if(gambling[openGamblerAddress[i]].bet == _vrf && gambling[openGamblerAddress[i]].isOpen==true)          //if user has an open bet and wins
            {
                gambling[openGamblerAddress[i]].balance = (gambling[openGamblerAddress[i]].balance)*2;
                emit wonBet(openGamblerAddress[i], gambling[openGamblerAddress[i]].bet);
            }
            gambling[openGamblerAddress[i]].isOpenBet = false;
        }
    }

    function vrf() public view returns (bytes32 result) {
    uint[1] memory bn;
    bn[0] = block.number;
    assembly {
      let memPtr := mload(0x40)
      if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
        invalid()
      }
      result := mload(memPtr)
    }
  }
  
}
