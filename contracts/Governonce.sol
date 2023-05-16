// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./IGovernance.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";

contract Governance is
    IGovernance,
    Governor,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    address public automation;

    CurrentProposal public currentProposal;

    uint256 public executionDelay = 1 minutes;

    constructor(
        IVotes _token,
        address _automation
    )
        Governor("Governance")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {
        automation = _automation;
    }

    modifier onlyAutomation() {
        require(msg.sender == automation);
        _;
    }

    function setAutomation(address _automation) public {
        require(msg.sender == address(this), "Only governance can access!");
        automation = _automation;
    }

    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public pure override returns (uint256) {
        return 10; // 10 block
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
        require(
            state(currentProposal.proposalId) == ProposalState.Canceled ||
                state(currentProposal.proposalId) == ProposalState.Defeated ||
                state(currentProposal.proposalId) == ProposalState.Executed
        );
        currentProposal.proposalId = super.propose(
            targets,
            values,
            calldatas,
            description
        );
        currentProposal.description = keccak256(bytes(description));
        currentProposal.executionTime =
            block.timestamp +
            165 seconds +
            executionDelay;
        return currentProposal.proposalId;
    }

    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public {
        _cancel(targets, values, calldatas, descriptionHash);
        delete currentProposal;
    }

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        public
        payable
        override(IGovernance, Governor)
        onlyAutomation
        returns (uint256)
    {
        super.execute(targets, values, calldatas, descriptionHash);
        return currentProposal.proposalId;
    }

    function getCurrentProposal() public view returns (CurrentProposal memory) {
        return currentProposal;
    }

    function isReadyToExecution() public view returns (bool) {
        return
            (state(currentProposal.proposalId) == ProposalState.Succeeded) ||
            (state(currentProposal.proposalId) == ProposalState.Queued);
    }
}
