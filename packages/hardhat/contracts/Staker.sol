// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

    ExampleExternalContract public exampleExternalContract;
    mapping ( address => uint256 ) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline ;
    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
        deadline = block.timestamp + 1 days;
    }

   

    event Stake(address sender, uint256 amount);

    modifier deadlineExpired() {
        require(block.timestamp >= deadline, "Deadline not reached.");
        _;
    }

    modifier deadlineNotExpired() {
        require(block.timestamp < deadline, "Already passed deadline.");
        _;
    }

    modifier thresholdReached() {
        require(address(this).balance >= threshold, "Threshold not reached.");
        _;
    }

    modifier openForWithdraw() {
        require(address(this).balance < threshold, "You aren't allowed to withdraw funds from this contract yet");
        _;
    }
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable deadlineNotExpired {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }
  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    function execute() public deadlineExpired thresholdReached  {
        exampleExternalContract.complete{value: address(this).balance}();
    }


  // Add a `withdraw(address payable)` function lets users withdraw their balance
    function withdraw(address payable _to) public deadlineExpired openForWithdraw
    {
        uint256 withdrawalAmount = balances[msg.sender];
        require(withdrawalAmount > 0, "Not enough balance.");
        balances[msg.sender] = 0;
        (bool sent, ) = _to.call{value: withdrawalAmount}("");
        require(sent, "Failed to transfer eth.");
    }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        return block.timestamp > deadline ? 0 : deadline - block.timestamp;
    }

  // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }

}
