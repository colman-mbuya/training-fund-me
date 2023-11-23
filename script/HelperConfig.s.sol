// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {MockPyth} from "../test/mock/MockPyth.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
        bytes32 priceId;
    }
    NetworkConfig public activeNetworkConfig;
    bytes32 private constant mockPriceId = 0x0000000000000000000000000000000000000000000000000000000000000001;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x2880aB155794e7179c9eE2e38200202908C17B43,
            priceId: 0xca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // This to avoid creating the Mock Pyth contract again when running multiple tests
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockPyth mockPriceFeed = new MockPyth();
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mockPriceFeed),
            priceId: mockPriceId
        });
    }

    function getPriceFeed() public view returns (address) {
        return activeNetworkConfig.priceFeed;
    }

    function getPriceId() public view returns (bytes32) {
        return activeNetworkConfig.priceId;
    }
}