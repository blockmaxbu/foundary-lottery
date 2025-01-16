//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
//Remapping isn't working for some reason
// import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

struct ChainConfig {
    uint256 entranceFee;
    uint256 interval;
    address VRFCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;
}


contract Constants {
    //VRF Mock Values
    uint96 public constant MOCK_BASE_FEE = 0.25 ether;
    uint96 public constant MOCK_GAS_PRICE_LIMIT = 1e9;

    //LINK/ETH price
    int256 public constant MOCK_WEI_PER_UNIT_LINK = 3e15;

    uint256 public constant SEPOLIA_CHAIN_ID = 1115511;
    uint256 public constant LOCAL_Chain_ID = 31337;
}

contract DeployConfig is Constants, Script {
    error ChainConfig__ChainNotSupported(uint256 chainId);

    

    ChainConfig public localChainConfig;
    mapping(uint256 => ChainConfig) public chainConfigs;

    constructor() {
        chainConfigs[SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getChainConfig(uint256 chainId) public returns (ChainConfig memory) {
        if (chainConfigs[chainId].VRFCoordinator != address(0)) {
            return chainConfigs[chainId];
        } else if (chainId == LOCAL_Chain_ID) {
            return getAnvilEthConfig();
        } else {
            revert ChainConfig__ChainNotSupported(chainId);
        }
    }

    function getConfig() public returns (ChainConfig memory) {
        return getChainConfig(block.chainid);
    }

    function getSepoliaEthConfig() public pure returns (ChainConfig memory) {
        return ChainConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            VRFCoordinator: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 200000,
            subscriptionId: 0
        });
    }

    function getAnvilEthConfig() private returns (ChainConfig memory) {
        if(localChainConfig.VRFCoordinator != address(0)) {
            return localChainConfig;
        }
        //we need to mock the chainlink VRF
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LIMIT, MOCK_WEI_PER_UNIT_LINK);
        vm.stopBroadcast();

        ChainConfig memory anvilConfig = ChainConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            VRFCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 200000,
            subscriptionId: 0
        });
        localChainConfig = anvilConfig;
        return anvilConfig;

    }
}
