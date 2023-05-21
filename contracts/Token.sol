// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./IToken.sol";

contract Token is IToken, ERC20Votes {
    uint256 public s_maxSupply = 1000000000000000000000000;

    constructor()
        ERC20("GovernanceToken", "GT")
        ERC20Permit("GovernanceToken")
    {}

    function mint() public payable {
        require(msg.value == 0.025 ether, "Not enough ETH!");
        _mint(msg.sender, s_maxSupply / 4);
    }

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._burn(account, amount);
    }
}
