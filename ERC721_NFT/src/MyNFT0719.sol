// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title 0719MyNFT
/// @notice ERC721 NFT contract with URI-based minting, built on OpenZeppelin v5.
///         Each NFT is minted with a unique token URI that points to its metadata.
contract MyNFT0719 is ERC721, ERC721URIStorage, Ownable {
    /// @notice The next token ID to be minted.
    uint256 private _nextTokenId;

    /// @notice Emitted when a new NFT is minted.
    /// @param to The address that received the NFT.
    /// @param tokenId The ID of the minted token.
    /// @param uri The token URI of the minted NFT.
    event Minted(address indexed to, uint256 indexed tokenId, string uri);

    /// @param initialOwner The address that will own the contract and have minting rights.
    constructor(address initialOwner)
        ERC721("0719MyNFT", "MNFT")
        Ownable(initialOwner)
    {}

    /// @notice Mint a new NFT with a specific URI.
    ///         Only callable by the contract owner.
    /// @param to The recipient address of the newly minted NFT.
    /// @param uri The token URI pointing to the NFT metadata.
    /// @return tokenId The ID of the newly minted token.
    function safeMint(address to, string memory uri)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit Minted(to, tokenId, uri);
        return tokenId;
    }

    /// @notice Mint multiple NFTs in a single transaction.
    ///         Only callable by the contract owner.
    /// @param to The recipient address for all newly minted NFTs.
    /// @param uris Array of token URIs, one per NFT to mint.
    /// @return tokenIds Array of minted token IDs.
    function safeMintBatch(address to, string[] calldata uris)
        external
        onlyOwner
        returns (uint256[] memory)
    {
        uint256 length = uris.length;
        uint256[] memory tokenIds = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokenIds[i] = safeMint(to, uris[i]);
        }
        return tokenIds;
    }

    /// @notice Get the next token ID that will be minted.
    /// @return The next token ID.
    function nextTokenId() external view returns (uint256) {
        return _nextTokenId;
    }

    /// @notice Returns the total number of tokens minted so far.
    /// @return The total supply of minted tokens.
    function totalSupply() external view returns (uint256) {
        return _nextTokenId;
    }

    // --- Overrides required by Solidity for multiple inheritance ---

    /// @inheritdoc ERC721
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /// @inheritdoc ERC721
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
