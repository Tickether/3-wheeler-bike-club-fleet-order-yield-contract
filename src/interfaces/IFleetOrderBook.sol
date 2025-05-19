// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title 3wb.club fleet order book interface V1.0
/// @notice interface for pre-orders for fractional and full investments in 3-wheelers
/// @author Geeloko

interface IFleetOrderBook {

    /// @notice Get the balance of a fleet order
    function balanceOf(uint256 id, address owner) external view returns (uint256);

    /// @notice Get the total number of fleet orders
    function totalFleet() external view returns (uint256);

    /// @notice Get the last fleet fraction ID
    function lastFleetFractionID() external view returns (uint256);

    /// @notice Get the maximum number of fleet orders
    function maxFleetOrder() external view returns (uint256);

    /// @notice Get the price per fleet fraction in USD
    function fleetFractionPrice() external view returns (uint256);

    /// @notice Get the minimum number of fractions per fleet order
    function MIN_FLEET_FRACTION() external view returns (uint256);

    /// @notice Get the maximum number of fractions per fleet order
    function MAX_FLEET_FRACTION() external view returns (uint256);

    /// @notice Get the maximum number of fleet orders per address
    function MAX_FLEET_ORDER_PER_ADDRESS() external view returns (uint256);

    /// @notice Get the maximum number of fleet orders that can be updated in bulk
    function MAX_BULK_UPDATE() external view returns (uint256);

    /// @notice Get the maximum number of fleet orders that can be purchased in bulk
    function MAX_ORDER_MULTIPLE_FLEET() external view returns (uint256);

    /// @notice Get the status of a fleet order
    function fleetOrderStatus(uint256 id) external view returns (uint256);

    /// @notice Check if an ERC20 token is accepted for fleet orders
    function fleetERC20(address token) external view returns (bool);

    /// @notice Get the fleet orders owned by an address
    function getFleetOwned(address owner) external view returns (uint256[] memory);

    /// @notice Get the owners of a fleet order
    function getFleetOwners(uint256 id) external view returns (address[] memory);

    /// @notice Check if a fleet order is fractioned
    function fleetFractioned(uint256 id) external view returns (bool);

    /// @notice Get the total fractions of a fleet order
    function totalFractions(uint256 id) external view returns (uint256);

    /// @notice Get the current status of a fleet order as a string
    function getFleetOrderStatus(uint256 id) external view returns (string memory);
}
