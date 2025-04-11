pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 amountOfTokens = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = owner().call{ value: balance }("");
        require(success, "Transfer failed");
    }

    function sellTokens(uint256 amount) public {
        uint256 ethAmount = amount / tokensPerEth;
        require(address(this).balance >= ethAmount, "Vendor has insufficient ETH");

        // Transfer tokens from user to Vendor
        require(yourToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Transfer ETH to user
        (bool success, ) = msg.sender.call{ value: ethAmount }("");
        require(success, "ETH transfer failed");

        emit SellTokens(msg.sender, amount, ethAmount);
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
}
