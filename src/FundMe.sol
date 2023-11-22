// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {IPyth} from "pyth-sdk-solidity/IPyth.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    address s_priceFeedAddress = 0x2880aB155794e7179c9eE2e38200202908C17B43;
    bytes32 s_priceId = 0xca80ba6dc32e08d06f1aa886011eed1d77c77be9eb761cc10d72b7d0a2fd57a6;
    IPyth s_priceFeed = IPyth(s_priceFeedAddress);
    function testPriceFeed() public view returns (uint256) {
        uint256 testValue = 1;
        return testValue.getConversionRate(s_priceFeed, s_priceId);
    }

}