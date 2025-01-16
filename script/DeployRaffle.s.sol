//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {ChainConfig, DeployConfig} from "./DeployConfig.s.sol";

contract DeployRaffle is Script {
    function run() public returns (Raffle, ChainConfig memory) {}
        // Deploy Raffle contract
        DeployConfig deployConfig = new DeployConfig();
        ChainConfig memory config = deployConfig.getConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle();
        vm.stopBroadcast();
        return (raffle, config);
    }
}
