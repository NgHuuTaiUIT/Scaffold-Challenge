// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
contract ExampleExternalContract is Ownable{

    bool public completed;

    modifier notCompleted() {
        require(completed == false, "Already completed.");
        _;
    }

    function complete() public payable notCompleted{
        completed = true;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address payable _to) public onlyOwner {
        (bool sent, ) = _to.call{value: address(this).balance}("");
        require(sent, "Failed to transfer eth.");
    }
}
