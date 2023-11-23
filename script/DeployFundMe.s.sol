// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        //To do - Figure out why I needed to write getters since accessing the struct members did not work with error
        //Error (9582): Member "priceFeed" not found or not visible after argument-dependent lookup in function () view external returns (address,bytes32).
        
        address priceFeed = helperConfig.getPriceFeed();
        bytes32 priceId = helperConfig.getPriceId();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed, priceId);
        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}