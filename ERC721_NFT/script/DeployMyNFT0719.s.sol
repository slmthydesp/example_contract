// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {MyNFT0719} from "../src/MyNFT0719.sol";

/// @title DeployMyNFT0719
/// @notice Deployment script for the 0719MyNFT contract.
///         Signs transactions via keystore: ~/.foundry/keystores/mytoken-sepolia
contract DeployMyNFT0719 is Script {
    function setUp() public {}

    function run() public {
        // INITIAL_OWNER: the address that will own the NFT contract and have minting rights.
        // Set this to your keystore account address.
        address initialOwner = vm.envAddress("INITIAL_OWNER");

        // startBroadcast() without arguments — Foundry injects the keystore
        // account (from --keystore flag) as the transaction sender.
        vm.startBroadcast();

        MyNFT0719 nft = new MyNFT0719(initialOwner);
        console.log("MyNFT0719 deployed at:", address(nft));
        console.log("Initial owner:", initialOwner);
        console.log("Token name:", nft.name());
        console.log("Token symbol:", nft.symbol());

        vm.stopBroadcast();
    }
}
