// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//URIStorage basically ensures that the URI of the off-chain metadata of the NFT is stored onchain when you mint it
//from the token URI we can get the token ID

contract BengalTigers is ERC2981, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("BengalTigers", "BGT") {
        // Let's set a default royalty whenever a token is created
        _setDefaultRoyalty(msg.sender, 100); //100 basis points = 1 percent
    }

    //Contract inherited from multiple base classes with supportsInterface function so we override it

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //overriding the erc2981 burn function
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    //allowing the above _burn function to be called publicly
    function burnNFT(uint256 tokenId) public {
        _burn(tokenId);
    }

    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        //increment the token ID by one when minting new NFT

        _tokenIds.increment();

        //new ID is the incremented Id

        uint256 newItemId = _tokenIds.current();

        _safeMint(recipient, newItemId); //using safe mint function of ERC721
        _setTokenURI(newItemId, tokenURI); //setting the token URI with the given uri for the new token

        return newItemId; //return the freshly minted tokenId
    }

    function mintNFTWithRoyalty(
        address recipient,
        string memory tokenURI,
        address royaltyReceiver,
        uint96 fees
    ) public onlyOwner returns (uint256) {
        //minting the NFT
        uint256 tokenId = mintNFT(recipient, tokenURI);
        //setting the royalty for the freshly minted token
        _setTokenRoyalty(tokenId, royaltyReceiver, fees);

        return tokenId;
    }
}
