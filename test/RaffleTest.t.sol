// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "src/Raffle.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {ChainConfig} from "script/DeployConfig.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    ChainConfig public config;

    address public player1 = makeAddr("player1");
    uint256 public constant DEFAULT_PLAYER_BALANCE = 10 ether;

    unit256 private entranceFee = 0.001 ether;


    event RaffleEntered(address indexed player);

    function setUp() external {
        DeployRaffle contractDeployer = new DeployRaffle();
        (raffle, config) = contractDeployer.run();

        vm.deal(player1, DEFAULT_PLAYER_BALANCE);
    }

    function testRaffleInitalizesInOpenState() public view{
        assert(raffle.getState() == Raffle.RaffleState.Open);
    }

    function testPlayerEntersRaffleWithoutEnoughEther() public {
        //Arrange
        vm.prank(player1);
        //Act & Assert
        vm.expectRevert(Raffle.Raffel__NotEnoughEtherSent.selector);
        raffle.enter();

    }

    function testPlayerEnterRaffleSuccesfully() public {
        //Arrange
        vm.prank(player1);
        //Act
        raffle.enter{value: entranceFee}();
        //Assert
        assert(raffle.getPlayer(0) == player1);
    }

    function testPlayerEnterRaffleEvent() public {
        //Arrange
        vm.prank(player1);
        //Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(player1);
        raffle.enter{value: entranceFee}();
        //Assert
    }   

}