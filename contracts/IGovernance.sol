// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IGovernance {
    struct CurrentProposal {
        uint256 proposalId;
        uint256 executionTime;
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        bytes32 description;
    }

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) external payable returns (uint256);

    function getCurrentProposal()
        external
        view
        returns (CurrentProposal memory);

    function isReadyToExecution() external view returns (bool);
}
