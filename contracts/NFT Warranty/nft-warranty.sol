// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WarrantyNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    address internal contractOwner;

    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isSeller;

    mapping(uint256 => bool) public productTransferable;
    mapping(uint256 => uint256) public productWarrantyPeriod;

    mapping(uint256 => address) public sellerOf;
    mapping(uint256 => uint256) public issueTime;
    mapping(uint256 => bool) public transferable;
    mapping(uint256 => uint256) public warrantyPeriod;

    event Repair(uint256 indexed tokenID);
    event Replace(uint256 indexed tokenID, uint256 indexed newTokenID);

    modifier adminOnly() {
        require(isAdmin[msg.sender], "Admin only function");
        _;
    }

    modifier sellerOnly() {
        require(isSeller[msg.sender], "Seller only function");
        _;
    }

    modifier adminOrSellerOnly() {
        require(
            isAdmin[msg.sender] || isSeller[msg.sender],
            "Admin or Seller only function"
        );
        _;
    }

    /**
     * @dev if the product with tokenID exists or not
     */
    modifier exists(uint256 tokenID) {
        require(
            ownerOf(tokenID) != address(0),
            "The product either does not exist or has not been sold yet"
        );
        _;
    }

    /**
     * @dev if the product with tokenID is in warranty period or not
     */
    modifier inWarranty(uint256 tokenID) {
        require(
            issueTime[tokenID] + warrantyPeriod[tokenID] > block.timestamp,
            "The product is not in warranty period"
        );
        _;
    }

    /**
     * @dev verify if the seller is the one attempting repairs or replacements
     */
    modifier verifySeller(uint256 tokenID) {
        require(sellerOf[tokenID] == msg.sender, "You are not the seller");
        _;
    }

    constructor() ERC721("Warranty", "W") {
        contractOwner = msg.sender;
        isAdmin[contractOwner] = true;
    }

    /**
     * @notice Add a new admin
     * @dev Only the contract owner and an existing admin can add a new admin
     * @param _admin The new admin address
     */
    function addAdmin(address _admin) public adminOnly {
        isAdmin[_admin] = true;
    }

    /**
     * @notice Remove an admin
     * @dev Only the contract owner and an existing admin can remove an admin. An admin can remove themselves.
     * @param _admin The admins address to remove
     */
    function removeAdmin(address _admin) public adminOnly {
        isAdmin[_admin] = false;
    }

    /**
     * @notice Add a new seller
     * @dev Only the contract owner and the admins can add a new seller
     * @param _seller The new seller address to add
     */
    function addSeller(address _seller) public adminOnly {
        isSeller[_seller] = true;
    }

    /**
     * @notice Remove a seller
     * @dev Only the contract owner and the admins can remove seller
     * @param _seller The sellers address to remove
     */
    function removeSeller(address _seller) public adminOnly {
        isSeller[_seller] = false;
    }

    /**
     * @notice add a new product
     * @dev only a registered seller can add a new product
     * @param productID product ID of new product
     * @param _warrantyPeriod warranty period offered on the product
     * @param _isSoulbound if the product warranty is transferable or not
     */
    function addProduct(
        uint256 productID,
        uint256 _warrantyPeriod,
        bool _isSoulbound
    ) public sellerOnly {
        productWarrantyPeriod[productID] = _warrantyPeriod;
        productTransferable[productID] = !_isSoulbound;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://";
    }

    /**
     * @notice mints a new token for the given buyer
     * @dev serialNo of product is used as token id
     * @param buyer wallet address of the buyer
     * @param tokenID tokenID of the product
     */
    function mintWarrantyNFT(
        address buyer,
        uint256 productID,
        uint256 tokenID
    ) public sellerOnly {
        sellerOf[tokenID] = msg.sender;
        issueTime[tokenID] = block.timestamp;
        warrantyPeriod[tokenID] = productWarrantyPeriod[productID];
        _safeMint(buyer, tokenID);
        _setTokenURI(tokenID, Strings.toString(productID));
    }

    /**
     * @notice Emits an event when the product is repaired
     * @param tokenID token ID of the product repaired
     */
    function repairProduct(uint256 tokenID)
        public
        sellerOnly
        exists(tokenID)
        inWarranty(tokenID)
        verifySeller(tokenID)
    {
        emit Repair(tokenID);
    }

    /**
     * @notice Emits an event when the product is replaced
     * @param tokenID token ID of the product to be replaced
     * @param newTokenID token ID of the new product
     */
    function replaceProduct(uint256 tokenID, uint256 newTokenID)
        public
        sellerOnly
        exists(tokenID)
        inWarranty(tokenID)
        verifySeller(tokenID)
    {
        issueTime[newTokenID] = issueTime[tokenID];
        emit Replace(tokenID, newTokenID);
    }

    function isOwner(uint256 tokenID) public view returns (bool) {
        if (ownerOf(tokenID) == msg.sender) return true;
        else return false;
    }

    /**
     * @dev Prevents transfering of soulbound tokens
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenID
    ) internal virtual override {
        if (transferable[tokenID] == false) {
            require(
                from == address(0) || to == address(0),
                "Cannot transfer soulbound tokens"
            );
        }
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
