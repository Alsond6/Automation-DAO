// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Treasury is Ownable {
    constructor(address _governance) {
        transferOwnership(_governance);
    }

    function transfer(uint256 amount, address to) public onlyOwner {
        payable(to).transfer(amount);
    }
}
