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
    


    /// @notice Thrown when the token address is invalid
    error InvalidTokenAddress();
    /// @notice Thrown when the token address is already set
    error TokenAlreadySet();
    /// @notice Thrown when the user does not have enough tokens
    error NotEnoughTokens();


    /// @notice The fleet order book contract
    IFleetOrderBook public fleetOrderBookContract;
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



    /// @notice Pay fee in ERC20.
    /// @param erc20Contract The address of the ERC20 contract.
    function payFleetWeeklyInstallmentERC20( address erc20Contract) internal {
        IERC20 tokenContract = IERC20(erc20Contract);
        uint256 decimals = IERC20Metadata(erc20Contract).decimals();
        
        uint256 amount = 1 * (10 ** decimals);
        if (tokenContract.balanceOf(msg.sender) < amount) revert NotEnoughTokens();
        tokenContract.safeTransferFrom(msg.sender, address(this), amount);
    }



}
