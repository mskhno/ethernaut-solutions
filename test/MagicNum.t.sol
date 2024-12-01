// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/MagicNum.sol";
import "src/levels/MagicNumFactory.sol";

contract TestMagicNum is BaseTest {
    MagicNum private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new MagicNumFactory();
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
        level = MagicNum(levelAddress);

        // Check that the contract is correctly setup
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The goal here is to create a smart contract that always returns 42 and its size is less than 10 opcodes
        // Here we need to construct runtime bytecode and creation bytecode for the contract

        // Runtime code - the code of the contract, it needs to return 42

        // This  stores 42 with zeros on the left up to 32 bytes and returns the whole 32 bytes
        // PUSH1 0x2a
        // PUSH1 0
        // MSTORE
        // PUSH1 0x20
        // PUSH1 0
        // RETURN
        // bytecode: 602a60005260206000f3

        // Creation code - the code that creates the contract and executes constructor, it also needs to return runtime code
        // Since we need to just retun 42, we can just return the runtime code
        // PUSH10 0x602a60005260206000f3
        // PUSH1 0
        // MSTORE
        // PUSH1 0x0a
        // PUSH1 0x16
        // RETURN
        // bytecode: 69602a60005260206000f3600052600a6016f3

        // Now we can create the contract that will deploy this bytecode

        vm.startPrank(player, player);

        // Deploy the solver contract
        Factory factory = new Factory();
        address solver = factory.deploySolver();

        // Set the solver contract
        level.setSolver(solver);

        vm.stopPrank();
    }
}

contract Factory {
    function deploySolver() external returns (address addr) {
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        assembly {
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
    }
}
