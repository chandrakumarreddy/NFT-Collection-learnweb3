//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IWhitelist {
    function whitelistedAddresses(address) external view returns (bool);
}
