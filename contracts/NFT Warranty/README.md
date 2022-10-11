# Smart Contract for NFT Warranty

## Assumptions

-   Product ID - Identify a particular product.
-   Serial Number - Identify a particular product instance.
-   A product can be uniquely identified given its Product ID and Serial Number.
-   Token ID of NFT genrated for a product is `[Product ID][serial number]`.

## Structure

-   #### Owner

    Deployer of the smart contract.

-   #### Admin

    Admins of the smart contract.

    -   Can add/remove admins.
    -   Can add/remove sellers.

-   #### Seller
    Seller of the product/warranty (Brands).
    -   Add/remove products (specify warranty period of each product)
    -   Mint warranty of a product.
    -   Replace product (mint a new NFT and burn the old one).
