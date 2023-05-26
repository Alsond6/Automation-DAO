// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IToken.sol";

contract Treasury is Ownable {
    IToken public token;
    uint256 public balance;

    event Transferred(address to, uint256 amount);
    event Received(address from, uint256 amount);

    constructor(address _governance, address _token) {
        transferOwnership(_governance);
        token = IToken(_token);
        token.withdraw();
    }

    function transfer(address to, uint256 amount) public onlyOwner {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed!");
        emit Transferred(to, amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
