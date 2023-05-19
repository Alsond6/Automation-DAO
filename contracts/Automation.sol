// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IGovernance.sol";

contract Automation is AutomationCompatibleInterface, Ownable {
    IGovernance public governance;

    IGovernance.CurrentProposal public currentProposal;

    function setGovernance(address _governance) public onlyOwner {
        require(
            address(governance) == address(0),
            "Governance contract has already set!"
        );
        governance = IGovernance(_governance);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        currentProposal = governance.getCurrentProposal();
        upkeepNeeded =
            (currentProposal.proposalId != 0) &&
            (governance.isReadyToExecution()) &&
            (currentProposal.executionTime >= block.timestamp);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        currentProposal = governance.getCurrentProposal();
        require(
            (currentProposal.executionTime >= block.timestamp) &&
                (governance.isReadyToExecution()) &&
                (currentProposal.executionTime >= block.timestamp)
        );
        governance.execute(
            currentProposal.targets,
            currentProposal.values,
            currentProposal.calldatas,
            currentProposal.description
        );
    }
}
