// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MyNFT0719} from "../src/MyNFT0719.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyNFT0719Test is Test {
    MyNFT0719 public nft;
    address public owner = address(0x1);
    address public alice = address(0x2);
    address public bob = address(0x3);

    event Minted(address indexed to, uint256 indexed tokenId, string uri);

    function setUp() public {
        vm.prank(owner);
        nft = new MyNFT0719(owner);
    }

    // --- Deployment ---

    function test_Deployment_Name() public view {
        assertEq(nft.name(), "0719MyNFT");
    }

    function test_Deployment_Symbol() public view {
        assertEq(nft.symbol(), "MNFT");
    }

    function test_Deployment_Owner() public view {
        assertEq(nft.owner(), owner);
    }

    function test_Deployment_InitialSupply() public view {
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.nextTokenId(), 0);
    }

    // --- Minting ---

    function test_SafeMint_Success() public {
        string memory uri = "ipfs://QmTest/1";
        vm.prank(owner);

        vm.expectEmit(true, true, false, true);
        emit Minted(alice, 0, uri);

        uint256 tokenId = nft.safeMint(alice, uri);
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.tokenURI(0), uri);
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.nextTokenId(), 1);
    }

    function test_SafeMint_MultipleTokens() public {
        vm.startPrank(owner);

        nft.safeMint(alice, "ipfs://QmTest/1");
        nft.safeMint(alice, "ipfs://QmTest/2");
        nft.safeMint(bob, "ipfs://QmTest/3");

        vm.stopPrank();

        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.ownerOf(1), alice);
        assertEq(nft.ownerOf(2), bob);
        assertEq(nft.tokenURI(0), "ipfs://QmTest/1");
        assertEq(nft.tokenURI(1), "ipfs://QmTest/2");
        assertEq(nft.tokenURI(2), "ipfs://QmTest/3");
        assertEq(nft.totalSupply(), 3);
        assertEq(nft.nextTokenId(), 3);
    }

    function test_SafeMint_RevertIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        nft.safeMint(alice, "ipfs://QmTest/1");
    }

    function test_SafeMint_RevertIfZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert();
        nft.safeMint(address(0), "ipfs://QmTest/1");
    }

    // --- Batch Minting ---

    function test_SafeMintBatch_Success() public {
        string[] memory uris = new string[](3);
        uris[0] = "ipfs://QmTest/1";
        uris[1] = "ipfs://QmTest/2";
        uris[2] = "ipfs://QmTest/3";

        vm.prank(owner);
        uint256[] memory tokenIds = nft.safeMintBatch(alice, uris);

        assertEq(tokenIds.length, 3);
        assertEq(tokenIds[0], 0);
        assertEq(tokenIds[1], 1);
        assertEq(tokenIds[2], 2);
        assertEq(nft.totalSupply(), 3);
    }

    function test_SafeMintBatch_RevertIfNotOwner() public {
        string[] memory uris = new string[](1);
        uris[0] = "ipfs://QmTest/1";

        vm.prank(alice);
        vm.expectRevert();
        nft.safeMintBatch(alice, uris);
    }

    // --- Token URI ---

    function test_TokenURI_RevertIfTokenNotMinted() public {
        vm.expectRevert();
        nft.tokenURI(999);
    }

    // --- Transfers ---

    function test_TransferFrom() public {
        vm.prank(owner);
        nft.safeMint(alice, "ipfs://QmTest/1");

        vm.prank(alice);
        nft.transferFrom(alice, bob, 0);

        assertEq(nft.ownerOf(0), bob);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(owner);
        nft.safeMint(alice, "ipfs://QmTest/1");

        vm.prank(alice);
        nft.approve(bob, 0);

        vm.prank(bob);
        nft.transferFrom(alice, bob, 0);

        assertEq(nft.ownerOf(0), bob);
    }

    // --- ERC721 Interface Support ---

    function test_SupportsInterface_ERC721() public view {
        assertTrue(nft.supportsInterface(type(IERC721).interfaceId));
    }
}
