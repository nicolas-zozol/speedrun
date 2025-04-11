// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;

    // Deadline of 72 hours
    uint256 public deadline = block.timestamp + 96 hours;
    bool public deadlineReached = false;

    // Events for tracking execute outcomes
    event CompleteSuccess(uint256 amount);
    event CompleteFail(uint256 amount);
    event DeadlineReach();

    // Event to emit when a stake is made
    event Stake(address indexed sender, uint256 amount);

    // Modifier to check if external contract is not completed
    modifier notCompleted() {
        require(!deadlineReached, "Deadline already reached");
        require(!exampleExternalContract.completed(), "External contract already completed");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()

    // Payable function to accept ETH and track balances
    function stake() public payable {
        // Require the deadline hasn't been reached
        require(block.timestamp <= deadline, "Staking period has ended");

        // Add the staked amount to the sender's balance
        balances[msg.sender] += msg.value;

        // Emit the staking event
        emit Stake(msg.sender, msg.value);
    }

    // Special function to receive ETH and call stake()
    receive() external payable {
        stake();
    }

    // Function to force the deadline to be reached (for testing)
    function force() public {
        if (!deadlineReached) {
            deadlineReached = true;
            emit DeadlineReach();
        }
    }

    // Function to execute the staking process after deadline
    function execute() public notCompleted {
        // Check if deadline has passed or was forced
        if (!deadlineReached && block.timestamp >= deadline) {
            deadlineReached = true;
            emit DeadlineReach();
        }
        require(deadlineReached, "Deadline not reached yet");

        // Check if threshold has been met
        if (address(this).balance >= threshold) {
            // Emit success event before the call
            emit CompleteSuccess(address(this).balance);

            // Call the external contract's complete function with all ETH
            (bool success, ) = address(exampleExternalContract).call{ value: address(this).balance }(
                abi.encodeWithSignature("complete()")
            );

            // Emit fail event if the call failed
            if (!success) {
                emit CompleteFail(address(this).balance);
            }

            require(success, "External contract call failed");
        }
    }

    // View function to get time left before deadline
    function timeLeft() public view returns (uint256) {
        if (deadlineReached) {
            return 0;
        }
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    // Function to withdraw staked ETH if threshold not met
    function withdraw() public notCompleted {
        // Check if deadline has passed
        require(deadlineReached || block.timestamp >= deadline, "Deadline not reached yet");

        // Check if threshold was not met
        require(address(this).balance < threshold, "Threshold met, cannot withdraw");

        // Get the user's balance
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");

        // Reset the user's balance before sending to prevent reentrancy
        balances[msg.sender] = 0;

        // Send the ETH back to the user
        (bool success, ) = msg.sender.call{ value: amount }("");
        require(success, "Withdrawal failed");
    }
}
