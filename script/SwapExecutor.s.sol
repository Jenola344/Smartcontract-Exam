// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SwapExecutor.sol";

contract ExecuteSwap is Script {
    function run() external {
        SwapExecutor executor = SwapExecutor(vm.envAddress("EXECUTOR_ADDRESS"));

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        uint256 id = executor.createSwap{value: 0.01 ether}(1e6);
        executor.executeSwap(id);

        vm.stopBroadcast();

        (,,, uint256 usdcReceived,) = executor.swapRequests(id);
        console.log("USDC received:", usdcReceived);
    }
}
