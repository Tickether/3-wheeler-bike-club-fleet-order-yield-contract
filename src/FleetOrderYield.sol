// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC6909 } from "solmate/tokens/ERC6909.sol";
//import { ERC6909 } from  "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC6909.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
//import { Ownable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
//import { Pausable } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//import { ReentrancyGuard } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
//import { Strings } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import { IERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
//import { IERC20Metadata } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import { SafeERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";


/// @title 3wb.club fleet order yield V1.0
/// @notice Manages yield for fractional and full investments in 3-wheelers
/// @author Geeloko



contract FleetOrderYield is ERC6909, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Emitted when the yield token is set
    event YieldTokenSet(address indexed newYieldToken);



    /// @notice Thrown when the token address is invalid
    error InvalidTokenAddress();
    /// @notice Thrown when the token address is already set
    error TokenAlreadySet();
    /// @notice Thrown when the amount is invalid
    error InvalidAmount();

    /// @notice Total interest deposited for a token representing a 3-wheeler.
    mapping(uint256 => uint256) public totalInterestDeposited;
    

    constructor() Ownable(msg.sender) { }
    
    IERC20 public yieldToken;

    function setYieldToken(address _yieldToken) external onlyOwner {
        if (_yieldToken == address(0)) revert InvalidTokenAddress();
        if (_yieldToken == address(yieldToken)) revert TokenAlreadySet();

        yieldToken = IERC20(_yieldToken);
        emit YieldTokenSet(_yieldToken);
    }

    function deposit(uint256 amount, uint256 id) external nonReentrant {
        if (amount == 0) revert InvalidAmount();

        uint256 decimals = IERC20Metadata(address(yieldToken)).decimals();

        uint256 interest = amount * 10 ** decimals;

        yieldToken.safeTransferFrom(msg.sender, address(this), interest);

        totalInterestDeposited[id] += interest;
    }

}
