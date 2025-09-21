// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title 3wb.club fleet order book interface V1.0
/// @notice interface for pre-orders for fractional and full investments in 3-wheelers
/// @author Geeloko

interface IFleetOrderBook {

    
    /// @notice Get the total number of fleet orders
    function totalFleet() external view returns (uint256);

     /// @notice Get the owners of a fleet order
    function getFleetOwners(uint256 id) external view returns (address[] memory);

    /// @notice Check if a fleet order is fractioned
    function getFleetFractioned(uint256 id) external view returns (bool);

    /// @notice Get the initial value per order of a fleet order
    function getFleetInitialValuePerOrder(uint256 id) external view returns (uint256);

    /// @notice Get the expected value per order of a fleet order
    function getFleetExpectedValuePerOrder(uint256 id) external view returns (uint256);

    /// @notice Get the lock period per order of a fleet order
    function getFleetLockPeriodPerOrder(uint256 id) external view returns (uint256);

    /// @notice Get the total fractions of a fleet order
    function totalSupply(uint256 id) external view returns (uint256);

    /// @notice Get the current status of a fleet order as a string
    function getFleetOrderStatus(uint256 id) external view returns (string memory);
}
