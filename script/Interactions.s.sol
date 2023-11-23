// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Sent %s ether to FundMe", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract BalanceFundMe is Script {

    function balanceFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        uint256 balance = mostRecentlyDeployed.balance;
        vm.stopBroadcast();
        console.log("Fund me balance is %d wei", balance);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        balanceFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).withdraw();
        uint256 ownerBalance = address(this).balance;
        vm.stopBroadcast();
        console.log("Owner balance after withdrawal is %d wei", ownerBalance);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}