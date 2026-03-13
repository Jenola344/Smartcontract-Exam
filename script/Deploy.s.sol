// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SwapExecutor.sol";

contract Deploy is Script {
    address constant ROUTER = 0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008;
    address constant USDC   = 0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        SwapExecutor executor = new SwapExecutor(ROUTER, USDC);
        vm.stopBroadcast();

        console.log("Deployed at:", address(executor));
    }
}
