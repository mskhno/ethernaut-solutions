// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/PuzzleWallet.sol";
import "src/levels/PuzzleWalletFactory.sol";

contract TestPuzzleWallet is BaseTest {
    PuzzleProxy private level;
    PuzzleWallet puzzleWallet;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PuzzleWalletFactory();
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
        level = PuzzleProxy(levelAddress);
        puzzleWallet = PuzzleWallet(address(level));

        // Check that the contract is correctly setup
        assertEq(level.admin(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */
        vm.startPrank(player, player);

        vm.stopPrank();
    }
}
