// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @dev Interface imports
import { IFleetOrderBook } from "./interfaces/IFleetOrderBook.sol";

/// @dev Solmate imports
import { ERC6909 } from "solmate/tokens/ERC6909.sol";
//import { ERC6909 } from  "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC6909.sol";

/// @dev OpenZeppelin utils imports
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @dev OpenZeppelin access imports
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


/// @title 3wb.club fleet order yield V1.0
/// @notice Manages yield for fractional and full investments in 3-wheelers
/// @author Geeloko



contract FleetOrderYield is ERC6909, Ownable, Pausable, ReentrancyGuard {
     constructor() Ownable(msg.sender) {}

    using SafeERC20 for IERC20;

    /// @notice Emitted when the yield token is set
    event YieldTokenSet(address indexed newYieldToken);
    /// @notice Emitted when the fleet weekly interest is updated
    event FleetWeeklyInterestUpdated(uint256 indexed newFleetWeeklyInterest);


    /// @notice Thrown when the token address is invalid
    error InvalidTokenAddress();
    /// @notice Thrown when the token address is already set
    error TokenAlreadySet();


    /// @notice weekly interest for a fleet in USD.
    uint256 public fleetWeeklyInterest;




    /// @notice Total interest distributed for a token representing a 3-wheeler.
    mapping(uint256 => uint256) public totalInterestDistributed;

    /// @notice The yield token for the fleet order yield contract.
    IERC20 public yieldToken;

    /// @notice Set the yield token for the fleet order yield contract.
    /// @param _yieldToken The address of the yield token.
    function setYieldToken(address _yieldToken) external onlyOwner {
        if (_yieldToken == address(0)) revert InvalidTokenAddress();
        if (_yieldToken == address(yieldToken)) revert TokenAlreadySet();

        yieldToken = IERC20(_yieldToken);
        emit YieldTokenSet(_yieldToken);
    }

    /// @notice Set the fleet weekly interest for the fleet order yield contract.
    /// @param _fleetWeeklyInterest The new fleet weekly interest.
    function setFleetWeeklyInterest(uint256 _fleetWeeklyInterest) external onlyOwner {
        fleetWeeklyInterest = _fleetWeeklyInterest;
        emit FleetWeeklyInterestUpdated(_fleetWeeklyInterest);
    }

    /// @notice Distribute the interest to the addresses.
    /// @param id The id of the fleet order.
    /// @param to The addresses to distribute the interest to.
    function distributeInterest(uint256 id, address[] calldata to) external nonReentrant {
        uint256 interest = totalInterestDistributed[id];

        for (uint256 i = 0; i < to.length; i++) {
            yieldToken.safeTransfer(to[i], interest);
        }
    }

/*
    function deposit(uint256 amount, uint256 id) external nonReentrant {
        if (amount == 0) revert InvalidAmount();

        uint256 decimals = IERC20Metadata(address(yieldToken)).decimals();

        uint256 interest = amount * 10 ** decimals;

        yieldToken.safeTransferFrom(msg.sender, address(this), interest);

        totalInterestDeposited[id] += interest;
    }

    function withdraw(uint256 id) external nonReentrant {
        totalInterestWithdrawn[id] += 0;
    }
*/

}
