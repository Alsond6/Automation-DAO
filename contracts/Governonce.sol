// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

contract Governonce is
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    AutomationCompatibleInterface
{
    struct CurrentProposal {
        uint256 proposalId;
        uint256 executionTime;
    }

    address public automation;

    CurrentProposal public currentProposal;

    uint256 public executionDelay = 1 hours;

    constructor(
        IVotes _token
    )
        Governor("Governonce")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {}

    modifier onlyAutomation() {
        require(msg.sender == automation);
        _;
    }

    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public pure override returns (uint256) {
        return 5; // 1 week
    }

    // The following functions are overrides required by Solidity.

    function quorum(
        uint256 blockNumber
    )
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override returns (uint256) {
        currentProposal.proposalId = super.propose(
            targets,
            values,
            calldatas,
            description
        );
        currentProposal.executionTime = block.timestamp + executionDelay;
        return currentProposal.proposalId;
    }

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable override onlyAutomation returns (uint256) {
        super.execute(targets, values, calldatas, descriptionHash);
        return currentProposal.proposalId;
    }

    function checkUpkeep(
        bytes calldata checkData
    ) external override returns (bool upkeepNeeded, bytes memory performData) {}

    function performUpkeep(bytes calldata performData) external override {}
}
