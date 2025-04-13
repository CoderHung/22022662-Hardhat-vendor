pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    receive() external payable {}

    function buyTokens() external payable {
        require(msg.value > 0, "Must send ETH to buy tokens");
        uint256 amountOfTokens = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= amountOfTokens, "Vendor has insufficient tokens");
        yourToken.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function sellTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(yourToken.balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        yourToken.transfer(address(this), _amount);
        payable(msg.sender).transfer(_amount / tokensPerEth);
    }
}
