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
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


/// @title 3wb.club fleet order yield V1.0
/// @notice Manages yield for fractional and full investments in 3-wheelers
/// @author geeloko.eth
/// 
/// @dev Role-based Access Control System:
/// - DEFAULT_ADMIN_ROLE: Can grant/revoke all other roles, highest privilege
/// - SUPER_ADMIN_ROLE: Can pause/unpause, set prices, max orders, add/remove ERC20s, update fleet status
/// - COMPLIANCE_ROLE: Can set compliance status for users
/// - WITHDRAWAL_ROLE: Can withdraw sales from the contract
/// 
/// @dev Security Benefits:
/// - Reduces risk of compromising the deployer wallet
/// - Allows delegation of specific functions to different admin addresses
/// - Provides granular control over different aspects of the contract
/// - Enables multi-signature or DAO governance for critical functions



contract FleetOrderYield is ERC6909, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Role definitions
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    bytes32 public constant WITHDRAWAL_ROLE = keccak256("WITHDRAWAL_ROLE");

    constructor() AccessControl() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SUPER_ADMIN_ROLE, msg.sender);
    }

    /// @notice Override supportsInterface to handle multiple inheritance
    /// @param interfaceId The interface ID to check
    /// @return bool True if the interface is supported
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC6909) returns (bool) {
        return AccessControl.supportsInterface(interfaceId) || ERC6909.supportsInterface(interfaceId);
    }


    


    /// @notice Emitted when the yield token is set
    event YieldTokenSet(address indexed newYieldToken);
    /// @notice Event emitted when fleet sales are withdrawn.
    event FleetManagementServiceFeeWithdrawn(address indexed token, address indexed to, uint256 amount);
    


    /// @notice Thrown when the token address is invalid
    error InvalidTokenAddress();
    /// @notice Thrown when the token address is already set
    error TokenAlreadySet();
    /// @notice Thrown when the user does not have enough tokens
    error NotEnoughTokens();
    /// @notice Thrown when the native token is not accepted
     error NoNativeTokenAccepted();


    /// @notice The fleet order book contract
    IFleetOrderBook public fleetOrderBookContract;
    /// @notice The yield token for the fleet order yield contract.
    IERC20 public yieldToken;
    

   

    /// @notice Set the yield token for the fleet order yield contract.
    /// @param _yieldToken The address of the yield token.
    function setYieldToken(address _yieldToken) external onlyRole(SUPER_ADMIN_ROLE) {
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


    /// @notice Withdraw sales from fleet order book.
    /// @param token The address of the ERC20 contract.
    /// @param to The address to send the sales to.
    function withdrawFleetManagementServiceFee(address token, address to) external nonReentrant {
        if (token == address(0)) revert InvalidTokenAddress();
        IERC20 tokenContract = IERC20(token);
        uint256 amount = tokenContract.balanceOf(address(this));
        if (amount == 0) revert NotEnoughTokens();
        tokenContract.safeTransfer(to, amount);
        emit FleetManagementServiceFeeWithdrawn(token, to, amount);
    }


    receive() external payable { revert NoNativeTokenAccepted(); }
    fallback() external payable { revert NoNativeTokenAccepted(); }



}
