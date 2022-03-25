pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);
  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
  // ToDo: create a payable buyTokens() function:
    function buyTokens() external payable{
        uint amountOfTokens = msg.value * tokensPerEth;
        (bool sent) = yourToken.transfer(msg.sender,amountOfTokens);
        require(sent, "Tranfer Token Failed");
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }
  // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() external onlyOwner{
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "WithDraw Failure");
    }
  // ToDo: create a sellTokens() function:
    function sellTokens(uint256 amountOfTokens) external payable{
        uint256 allowance = yourToken.allowance(msg.sender, address(this));
        require(allowance >= amountOfTokens, "You don't have enough allowance");
        bool transferSuccess = yourToken.transferFrom(msg.sender, address(this), amountOfTokens);
        require(transferSuccess, "Tokens transfer failed");

        uint256 amountOfEthsBack = amountOfTokens / tokensPerEth;
        (bool transferETHsSuccess, ) = msg.sender.call{value: amountOfEthsBack}("");
        require(transferETHsSuccess , "Transfer ETH failed");
        emit SellTokens(msg.sender, amountOfEthsBack, amountOfTokens);
    }

}
