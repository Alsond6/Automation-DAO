// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is Ownable {
    constructor() {}

    function transfer(uint256 amount, address to) public onlyOwner {}
}
