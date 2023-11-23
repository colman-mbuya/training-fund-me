// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract FundMeTest is StdCheats, Test {
    FundMe fundMe;
    HelperConfig helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant TINY_AMOUNT = 0.001 ether;
    uint256 public constant STARTING_PRANKED_USER_BALANCE = 10 ether;
    address public constant PRANKED_USER = address(1); //Todo look into how this works, but I assume this only applies when we are working with an anvil chain

    modifier funded() {
        vm.prank(PRANKED_USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance >= SEND_VALUE);
        _;
    }
    
    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helperConfig) = deployer.run();
        vm.deal(PRANKED_USER, STARTING_PRANKED_USER_BALANCE);
    }

    function testPriceFeedSetUpCorrectly() public {
        address fundMePriceFeed = address(fundMe.getPriceFeed());
        address expectedPriceFeed = helperConfig.getPriceFeed();
        assertEq(fundMePriceFeed, expectedPriceFeed);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.prank(PRANKED_USER);
        vm.expectRevert();
        fundMe.fund{value: TINY_AMOUNT}();      
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(PRANKED_USER);
        assertEq(SEND_VALUE, amountFunded);
    }

    function testFundUpdatesFundersArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, PRANKED_USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(PRANKED_USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawAfterMultipleFundingCalls() public funded {
        uint160 numberOfFunders = 10;
        uint160 startFundersAddrIndex = 2; //Addr 0 is special, 1 we already use

        for (uint160 i = startFundersAddrIndex; i < numberOfFunders + startFundersAddrIndex; i++) {
            hoax(address(i), STARTING_PRANKED_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}(); //No need to startprank, hoax does deal and prank
        }

        address ownerAddress = fundMe.getOwner();
        uint256 initialOwnerBalance = ownerAddress.balance;
        uint256 initialFundBalance = address(fundMe).balance;

        vm.startPrank(ownerAddress);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 finalOwnerBalance = ownerAddress.balance;
        uint256 finalFundBalance = address(fundMe).balance;

        assertEq(finalOwnerBalance, initialOwnerBalance + initialFundBalance);
        assertEq(finalFundBalance, 0);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - initialOwnerBalance);
    }



}