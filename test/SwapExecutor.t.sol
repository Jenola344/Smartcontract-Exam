// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SwapExecutor.sol";

/// @dev Mock router that pretends to swap and returns a fixed USDC amount
contract MockRouter {
    address public WETH = address(0xWETH);

    function swapExactETHForTokens(
        uint,
        address[] calldata,
        address to,
        uint
    ) external payable returns (uint[] memory amounts) {
        amounts = new uint[](2);
        amounts[0] = msg.value;
        amounts[1] = 20e6; // pretend we got 20 USDC
    }
}

contract SwapExecutorTest is Test {
    SwapExecutor executor;
    MockRouter   mockRouter;
    address      user = makeAddr("user");

    function setUp() public {
        mockRouter = new MockRouter();
        executor   = new SwapExecutor(address(mockRouter), address(0xUSDC));
        vm.deal(user, 1 ether);
    }

    function test_CreateSwap() public {
        vm.prank(user);
        uint256 id = executor.createSwap{value: 0.1 ether}(1e6);

        (address u, uint256 eth,,, bool executed) = executor.swapRequests(id);
        assertEq(u, user);
        assertEq(eth, 0.1 ether);
        assertFalse(executed);
    }

    function test_ExecuteSwap() public {
        vm.prank(user);
        uint256 id = executor.createSwap{value: 0.01 ether}(1e6);

        executor.executeSwap(id);

        (,,, uint256 usdcReceived, bool executed) = executor.swapRequests(id);
        assertTrue(executed);
        assertEq(usdcReceived, 20e6);
    }

    function test_RevertIf_NoEth() public {
        vm.expectRevert("Send ETH");
        executor.createSwap{value: 0}(1e6);
    }

    function test_RevertIf_AlreadyExecuted() public {
        vm.prank(user);
        uint256 id = executor.createSwap{value: 0.01 ether}(1e6);
        executor.executeSwap(id);

        vm.expectRevert("Already executed");
        executor.executeSwap(id);
    }
}
