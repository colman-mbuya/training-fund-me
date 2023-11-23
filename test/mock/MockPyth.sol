// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {PythStructs} from "pyth-sdk-solidity/PythStructs.sol";

contract MockPyth {
    int64 public constant ethPrice = 200000000000;
    int32 public constant expo = -8;
    uint64 public constant conf = 0;
    uint public publishTime = block.timestamp;

    function getPriceUnsafe(bytes32 priceId) public view returns (PythStructs.Price memory) {
        require(priceId != 0, "You need to pass through a priceId");
        return PythStructs.Price({
            price: ethPrice,
            conf: conf,
            expo: expo,
            publishTime: publishTime
        });
    }
}