//SPDX-License_identifier: UNLICENSED

/* This smart contract allows a parent to set up savings for their kids. 
Upon a certain maturity date, the kids can withdraw their money.
Only the designated parent (owner) can deposit money for the kids.
Only the specific kid can withdraw their own money.
*/

pragma solidity ^0.8.7;

contract CryptoKids {
    //owner Dad

    address owner;

    event logKidFundingReceived (address addr, uint amount, uint contractBalance);

    constructor () {
        owner = msg.sender;
    }

        //define Kid

    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;

    }

    Kid[] public kids;

    modifier onlyOwner () {
        require(msg.sender == owner, "only the owner can do this");
        _;
    }
    //add kid to contract
    function addKid(address payable walletAddress, string memory firstName, string memory lastName, uint releaseTime, uint amount, bool canWithdraw) public onlyOwner {
        
        kids.push( Kid( walletAddress,
        firstName,
        lastName,
        releaseTime,
        amount,
        canWithdraw));

    }

    //get balance
    function getBalance ()  public view returns (uint){
        return address(this).balance;
    }

     //deposit funds to contract, to a specific kid's account
    function deposit(address walletAddress) public payable {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance (address walletAddress) private {
        for (uint i = 0; i < kids.length; i++){
            if (kids[i].walletAddress == walletAddress){
            kids[i].amount += msg.value;
            emit logKidFundingReceived (walletAddress, msg.value, getBalance());
            }
        }
    }
   

    function getIndex (address walletAddress) view private returns (uint) {
        for (uint i = 0; i < kids.length; i++){
            if (kids[i].walletAddress == walletAddress){
            return i;
            }
        }
            return 999;
    }
    //check if kid can withdraw

    function availableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].releaseTime, "it's not time yet");
        if (block.timestamp > kids[i].releaseTime) {
            kids[i].canWithdraw = true;
        }
        else{
            kids[i].canWithdraw = false;
        }
        return kids[i].canWithdraw;

    }

    //withdraw money

    function withdraw (address payable walletAddress) payable public {
        
        uint i = getIndex (walletAddress);
        require(msg.sender == kids[i].walletAddress, "you must be the kid to withdraw");
        require(kids[i].canWithdraw == true, "you can't withdraw yet");
        kids[i].walletAddress.transfer(kids[i].amount);
      
    }
}
