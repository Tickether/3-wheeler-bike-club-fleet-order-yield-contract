// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @dev Interface imports
import { IFleetOrderBook } from "./interfaces/IFleetOrderBook.sol";

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



contract FleetOrderYield is AccessControl, ReentrancyGuard {
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
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl) returns (bool) {
        return AccessControl.supportsInterface(interfaceId);
    }


    


    /// @notice Emitted when the yield token is set
    event YieldTokenSet(address indexed newYieldToken);
    /// @notice Event emitted when fleet sales are withdrawn.
    event FleetManagementServiceFeeWithdrawn(address indexed token, address indexed to, uint256 amount);
    /// @notice Event emitted when the fleet management service fee wallet is set
    event FleetManagementServiceFeeWalletSet(address indexed newFleetManagementServiceFeeWallet);


    /// @notice Thrown when the token address is invalid
    error InvalidAddress();
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
    /// @notice The fleet management service fee wallet for the fleet order yield contract.
    address public fleetManagementServiceFeeWallet;
    

   

    /// @notice Set the yield token for the fleet order yield contract.
    /// @param _yieldToken The address of the yield token.
    function setYieldToken(address _yieldToken) external onlyRole(SUPER_ADMIN_ROLE) {
        if (_yieldToken == address(0)) revert InvalidAddress();
        if (_yieldToken == address(yieldToken)) revert TokenAlreadySet();

        yieldToken = IERC20(_yieldToken);
        emit YieldTokenSet(_yieldToken);
    }

    /// @notice Set the fleet management service fee wallet for the fleet order yield contract.
    /// @param _fleetManagementServiceFeeWallet The address of the fleet management service fee wallet.
    function setFleetManagementServiceFeeWallet(address _fleetManagementServiceFeeWallet) external onlyRole(SUPER_ADMIN_ROLE) {
       if (_fleetManagementServiceFeeWallet == address(0)) revert InvalidAddress();
        fleetManagementServiceFeeWallet = _fleetManagementServiceFeeWallet;
        emit FleetManagementServiceFeeWalletSet(_fleetManagementServiceFeeWallet);
    }



    /// @notice Pay fee in ERC20.
    /// @param erc20Contract The address of the ERC20 contract.
    function payERC20( address erc20Contract, uint256 amount) internal {
        IERC20 tokenContract = IERC20(erc20Contract);
        uint256 decimals = IERC20Metadata(erc20Contract).decimals();
        
        if (tokenContract.balanceOf(msg.sender) < amount * (10 ** decimals)) revert NotEnoughTokens();
        tokenContract.safeTransferFrom(msg.sender, address(this), amount * (10 ** decimals));
    }


    /// @notice Withdraw sales from fleet order book.
    /// @param token The address of the ERC20 contract.
    /// @param to The address to send the sales to.
    function withdrawFleetManagementServiceFee(address token, address to) external nonReentrant {
        if (token == address(0)) revert InvalidAddress();
        IERC20 tokenContract = IERC20(token);
        uint256 amount = tokenContract.balanceOf(address(this));
        if (amount == 0) revert NotEnoughTokens();
        tokenContract.safeTransfer(to, amount);
        emit FleetManagementServiceFeeWithdrawn(token, to, amount);
    }


    receive() external payable { revert NoNativeTokenAccepted(); }
    fallback() external payable { revert NoNativeTokenAccepted(); }
        // =================================================== ADMIN MANAGEMENT ====================================================

    /// @notice Grant compliance role to an address
    /// @param account The address to grant the compliance role to
    function grantComplianceRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(COMPLIANCE_ROLE, account);
    }

    /// @notice Revoke compliance role from an address
    /// @param account The address to revoke the compliance role from
    function revokeComplianceRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(COMPLIANCE_ROLE, account);
    }

    /// @notice Grant withdrawal role to an address
    /// @param account The address to grant the withdrawal role to
    function grantWithdrawalRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(WITHDRAWAL_ROLE, account);
    }

    /// @notice Revoke withdrawal role from an address
    /// @param account The address to revoke the withdrawal role from
    function revokeWithdrawalRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(WITHDRAWAL_ROLE, account);
    }

    /// @notice Grant super admin role to an address
    /// @param account The address to grant the super admin role to
    function grantSuperAdminRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(SUPER_ADMIN_ROLE, account);
    }

    /// @notice Revoke super admin role from an address
    /// @param account The address to revoke the super admin role from
    function revokeSuperAdminRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(SUPER_ADMIN_ROLE, account);
    }

    /// @notice Check if an address has compliance role
    /// @param account The address to check
    /// @return bool True if the address has compliance role
    function isCompliance(address account) external view returns (bool) {
        return hasRole(COMPLIANCE_ROLE, account);
    }

    /// @notice Check if an address has withdrawal role
    /// @param account The address to check
    /// @return bool True if the address has withdrawal role
    function isWithdrawal(address account) external view returns (bool) {
        return hasRole(WITHDRAWAL_ROLE, account);
    }

    /// @notice Check if an address has super admin role
    /// @param account The address to check
    /// @return bool True if the address has super admin role
    function isSuperAdmin(address account) external view returns (bool) {
        return hasRole(SUPER_ADMIN_ROLE, account);
    }



}
