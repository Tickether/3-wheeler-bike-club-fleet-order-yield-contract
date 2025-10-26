// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title 3wb.club fleet order book interface V1.0
/// @notice interface for pre-orders for fractional and full investments in 3-wheelers
/// @author Geeloko

interface IFleetOperatorBook {
    /// @notice Get the next fleet operator reservation
    function getNextFleetOperatorReservation() external view returns (address);
}
