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
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        uint256 proposalId = governance.getProposalId();
        uint256 executionTime = governance.getExecutionTime();
        upkeepNeeded =
            (proposalId != 0) &&
            (governance.isReadyToExecution()) &&
            (executionTime <= block.timestamp);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        uint256 proposalId = governance.getProposalId();
        uint256 executionTime = governance.getExecutionTime();
        require(
            (proposalId != 0) &&
                (executionTime <= block.timestamp) &&
                (governance.isReadyToExecution()),
            "Execution is not ready yet!"
        );
        governance.execute(
            governance.getTargets(),
            governance.getValues(),
            governance.getCalldatas(),
            governance.getDescription()
        );
    }
}
