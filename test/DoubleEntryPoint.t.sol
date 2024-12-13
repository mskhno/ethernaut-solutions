// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/DoubleEntryPoint.sol";
import "src/levels/DoubleEntryPointFactory.sol";

contract TestDoubleEntryPoint is BaseTest {
    DoubleEntryPoint private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DoubleEntryPointFactory();
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
        level = DoubleEntryPoint(levelAddress);

        // Check that the contract is correctly setup
    }

    function exploitLevel() internal override {
        /**
         * CODE YOUR EXPLOIT HERE
         */

        // There is a bug in the sweepToken() of the CryptoVault contract due to the way in which DoubleEntryPoint and LegacyToken interact
        // If we call sweepToken() with the address of the LegacyToken, we can withdraw DET from the vault even though we shouldn't be able to
        // Expected behavior is that the tranfer() function in LegacyToken will just send LGT tokens to sweepTokensRecipient
        // Instead, LegacyToken contract calls delegateTransfer() on DoubleEntryPoint because it has a delegate address set, the player gets DET tokens from the vault

        // So we have the bug, now we need to prevent it from happening with a detection bot
        // Forta contract is called before the delegateTransfer() function is executed, and that's where our bot would be passed msg.data of the delegateTransfer() call
        // Forta calls handleTransaction() on our detection bot, so here this passed msg.data can be decoded
        // To prevent the bug from being exploited, we need to check if the origSender passed to delegateTransfer(), since we want to reject sweepToken() calls with the LegacyToken address
        // If the origSender is the vault, we raise an alert
        // Before that though, in more of a real world scenario, we would need to check if the msg.sender is the Forta contract, and if the msg.data is indeed the delegateTransfer() call
        // We should also check if the call was actually made to delegateTransfer() and not some other function, that we maybe would handle differently
        // But to solve this level, the two lines above this one are not needed
        vm.startPrank(player, player);

        // Register the DetectionBot
        Forta forta = level.forta();
        DetectionBot bot = new DetectionBot(level.cryptoVault(), forta);
        forta.setDetectionBot(address(bot));

        vm.stopPrank();
    }
}

contract DetectionBot is IDetectionBot {
    address vault;

    Forta forta;

    constructor(address _vault, Forta _forta) public {
        vault = _vault;
        forta = _forta;
    }

    modifier onlyForta() {
        if (msg.sender != address(forta)) revert("Caller is not Forta");
        _;
    }

    // If the call is delegateTransfer() which only LegacyToken can call, and origSender is the vault, then raise an alert
    function handleTransaction(address user, bytes calldata msgData) external override onlyForta {
        bytes32 msgDataSelectorHash = keccak256(bytes(msgData[:4]));
        bytes32 delegateTransferSelectorHash = keccak256(
            abi.encodePacked(bytes4(keccak256("delegateTransfer(address,uint256,address)")))
        );

        if (msgDataSelectorHash == delegateTransferSelectorHash) {
            (, , address origSender) = abi.decode(msgData[4:], (address, uint256, address));
            if (origSender == vault) {
                forta.raiseAlert(user);
            }
        }
    }
}
