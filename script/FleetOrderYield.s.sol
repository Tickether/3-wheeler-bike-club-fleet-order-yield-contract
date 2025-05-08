// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FleetOrderYield} from "../src/FleetOrderYield.sol";

contract FleetOrderYieldScript is Script {
    FleetOrderYield public fleetOrderYield;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fleetOrderYield = new FleetOrderYield();

        vm.stopBroadcast();
    }
}
