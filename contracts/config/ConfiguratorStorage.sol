// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.15;

import "./CometConfiguration.sol";
// import "./marketupdates/MarketAdminPermissionCheckerInterface.sol";


contract ConfiguratorStorage is CometConfiguration {

    uint public version;

    mapping(address => Configuration) internal configuratorParams;

    /// @notice The governor of the protocol
    address public governor;

    /// @notice Mapping of Comet proxy addresses to their Comet factory contracts
    mapping(address => address) public factory;

    /// @notice MarketAdminPermissionChecker contract which is used to check if the caller has permission to perform market updates
    
    // MarketAdminPermissionCheckerInterface public marketAdminPermissionChecker;
}
