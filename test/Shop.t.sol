// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Shop.sol";
import "src/levels/ShopFactory.sol";

contract TestShop is BaseTest {
    Shop private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ShopFactory();
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
        levelAddress = payable(this.createLevelInstance{value: 0.001 ether}(true));
        level = Shop(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.isSold(), false);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */
        vm.startPrank(player, player);

        vm.stopPrank();
    }
}
