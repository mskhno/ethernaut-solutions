// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/GatekeeperOne.sol";
import "src/levels/GatekeeperOneFactory.sol";
import "forge-std/console.sol";

contract TestGatekeeperOne is BaseTest {
    GatekeeperOne private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new GatekeeperOneFactory();
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
        level = GatekeeperOne(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.entrant(), address(0));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // To pass gate 1, origin of the call must be different
        // So we need to use some relayer contract
        Exploiter exploit = new Exploiter();

        // Here we pass gate 3
        // Conversion from bigger to smaller types just truncates the higher bits
        // However, if we convert from smaller to bigger types, the higher bits are filled with 0
        // To pass the first line, we need to have 4 byte object equel 2 byte object. Is possible if the first 2 bytes of each are the same, and the rest is 0
        // To pass the second line, we need to have 8 byte object not equal to 4 byte object. Combined with the first line, we get 0x0000FFFF != 0xFFFFFFFF0000FFFF
        // To pass the third line, we have the same condition considering bytes equality, it's that those masked bytes have to equal the origin address
        bytes8 key = bytes8(uint64(uint160(address(player)))) & 0xFFFFFFFF0000FFFF;

        vm.prank(player, player);

        exploit.call(level, key);
    }
}

contract Exploiter {
    function call(GatekeeperOne level, bytes8 key) external {
        // To pass gate 2 we need to estimate gas
        // We can do this by trying to enter the level with different gas values
        // We can start from 80000 and go up to 8191

        // This worked at gas: 82121
        // for (uint256 i = 0; i <= 8191; i++) {
        //     try level.enter{gas: 80000 + i}(key) {
        //         console.log("Entered with gas: ", 80000 + i);
        //         break;
        //     } catch {
        //         continue;
        //     }
        // }

        level.enter{gas: 82121}(key);
    }
}
