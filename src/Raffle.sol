// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//Foundary remapping isn't working for some reason
import {VRFConsumerBaseV2Plus} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract Raffle is VRFConsumerBaseV2Plus{
    enum RaffleState {
        Open,
        isdrawing,
        Closed
    }

    error Raffel__NotEnoughEtherSent();
    error Raffel__StateNotOpen();

    uint256 s_subscriptionId;
    address vrfCoordinator;
    bytes32 s_keyHash;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  1;


    uint256 constant MIN_VALUE = 0.001 ether;
    address[] private _players;

    address private _lastWinner;
    RaffleState private _state;

    event RaffleEntered(address indexed player);


    constructor(uint256 subscriptionId, bytes32 keyHash, address coordinator, address link) VRFConsumerBaseV2Plus(coordinator, link) {
        _state = RaffleState.Open;

        s_subscriptionId = subscriptionId;
    }

    function enter() public payable {
        if (_state != RaffleState.Open) {
            revert Raffel__StateNotOpen();
        }
        if (msg.value < MIN_VALUE) {
            revert Raffel__NotEnoughEtherSent();
        }
        _players.push(msg.sender);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _players)));
    }

    function pickWinner() public {
        uint256 index = random() % _players.length;
        address winner = _players[index];
        payable(winner).transfer(address(this).balance);
        _lastWinner = winner;
    }

    function getState() public view returns (RaffleState) {
        return _state;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return _players[index];
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {

    }
}
