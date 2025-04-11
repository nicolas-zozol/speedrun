pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

contract DiceGame {
    uint256 public nonce = 0;
    uint256 public prize = 0;

    error NotEnoughEther();
    error FailedToSendEther();

    event Roll(address indexed player, uint256 amount, uint256 roll);
    event Winner(address winner, uint256 amount);

    constructor() payable {
        resetPrize();
    }

    function resetPrize() private {
        prize = ((address(this).balance * 10) / 100);
    }

    function rollTheDice() public payable {
        console.log("## DiceGame: Starting roll, msg.value:", msg.value);
        if (msg.value < 0.002 ether) {
            console.log("## XXXX DiceGame: Not enough ether!");
            revert NotEnoughEther();
        }

        console.log("## DiceGame: Calculating hash");
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce));
        uint256 roll = uint256(hash) % 16;

        console.log("## DiceGame: Roll:", roll);
        console.log("## DiceGame: Current nonce:", nonce);

        nonce++;
        prize += ((msg.value * 40) / 100);
        console.log("## DiceGame: Updated prize:", prize);

        emit Roll(msg.sender, msg.value, roll);

        if (roll > 5) {
            console.log("## DiceGame: Looser");
            return;
        }

        console.log("## DiceGame: Winner! Sending prize:", prize);
        uint256 amount = prize;
        console.log("## DiceGame: Attempting to send to:", msg.sender);
        (bool sent, ) = msg.sender.call{ value: amount }("");
        if (!sent) {
            console.log("## XXXXDiceGame: Failed to send Ether");
            revert FailedToSendEther();
        }

        resetPrize();
        emit Winner(msg.sender, amount);
        console.log("## DiceGame: sent money ", amount);
    }

    receive() external payable {}
}
