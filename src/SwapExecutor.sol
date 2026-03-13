// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV2Router {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

contract SwapExecutor {
    IUniswapV2Router public router;
    address public USDC;

    struct SwapRequest {
        address user;
        uint256 ethAmount;
        uint256 minUsdc;
        uint256 usdcReceived;
        bool executed;
    }

    uint256 public requestCount;
    mapping(uint256 => SwapRequest) public swapRequests;
    mapping(address => uint256[]) public userRequests;

    event SwapCreated(uint256 id, address user, uint256 ethAmount);
    event SwapExecuted(uint256 id, address user, uint256 usdcReceived);

    constructor(address _router, address _usdc) {
        router = IUniswapV2Router(_router);
        USDC = _usdc;
    }

    function createSwap(uint256 minUsdc) external payable returns (uint256 id) {
        require(msg.value > 0, "Send ETH");
        require(minUsdc > 0, "Set min USDC");

        id = requestCount++;
        swapRequests[id] = SwapRequest(msg.sender, msg.value, minUsdc, 0, false);
        userRequests[msg.sender].push(id);

        emit SwapCreated(id, msg.sender, msg.value);
    }

    function executeSwap(uint256 id) external {
        SwapRequest storage req = swapRequests[id];
        require(!req.executed, "Already executed");
        require(req.ethAmount > 0, "Invalid request");

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = USDC;

        uint[] memory amounts = router.swapExactETHForTokens{value: req.ethAmount}(
            req.minUsdc,
            path,
            req.user,
            block.timestamp + 300
        );

        req.usdcReceived = amounts[1];
        req.executed = true;

        emit SwapExecuted(id, req.user, amounts[1]);
    }

    function getUserHistory(address user) external view returns (uint256[] memory) {
        return userRequests[user];
    }
}
