// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {IPyth} from "pyth-sdk-solidity/IPyth.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {console} from "forge-std/Test.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5;
    address private immutable i_owner;
    address[] private s_funders;
    mapping(address funder => uint256 amount) private s_addressToAmountFunded;
    IPyth private s_priceFeed;
    bytes32 private s_priceFeedId;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed, bytes32 priceFeedId) {
        s_priceFeed = IPyth(priceFeed);
        s_priceFeedId = priceFeedId;
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed, s_priceFeedId) >= MINIMUM_USD, "You need to send more Ether");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        address[] memory funders = s_funders; //Gas savings as we won't need to loop over a storage array
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = s_funders[i];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }


    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (IPyth) {
        return s_priceFeed;
    }

    // address s_priceFeedAddress = 0x2880aB155794e7179c9eE2e38200202908C17B43;
    // bytes32 s_priceId = 0xca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6;
    // IPyth s_priceFeed = IPyth(s_priceFeedAddress);

    // function testPriceFeed() public view returns (uint256) {
    //     uint256 testValue = 1;
    //     return testValue.getConversionRate(s_priceFeed, s_priceId);
    // }

}