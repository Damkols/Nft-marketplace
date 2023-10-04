# ERC721 Marketplace Contract

## Contract Outline

### State Variables

- `uint public listingCounter`: A counter to keep track of the number of listings.

### Structs

- `struct Listing`: A struct representing an ERC721 listing with fields for the listingId, order creator, ERC721 token address, token ID, price, signature, deadline and isSold.

### Mapping

- `mapping(uint => Listing) public listings`: A mapping that associates listing IDs with their respective `Listing` structs.

## `createListing` Function

#### Parameters

- `address _tokenAddress`: The address of the ERC721 token.
- `uint _tokenID`: The token ID of the ERC721 token.
- `uint _price`: The price of the listing in ether.
- `bytes memory _signature`: The seller's signature of the order data.
- `uint _deadline`: The deadline for the listing.

#### Preconditions

- **Owner Check**:

  - Check that `msg.sender` is the owner of the token using `ownerOf(_tokenID)`.

- **Approval Check**:

  - Check that `msg.sender` has approved the contract to spend the ERC721 token using `isApprovedForAll(msg.sender, address(this))`.

- **Token Address Validation**:

  - Check that `_tokenAddress` is not the zero address (`address(0)`).
  - Check if `_tokenAddress` has code (is a smart contract).

- **Price Check**:

  - Check that `_price` is greater than 0.

- **Deadline Check**:
  - Check that `_deadline` is greater than `block.timestamp`.

#### Logic

- Create a new `Listing` struct with the provided information.
- Increment `listingCounter` to generate a new listing ID.
- Store the `Listing` in the `listings` mapping using the new listing ID.

## `executeListing` Function

#### Parameters

- `uint _listingId`: The ID of the listing to be executed.

#### Preconditions

- **Listing ID Check**:

  - Check that `_listingId` is less than `listingCounter`.

- **Payment Check**:

  - Check that `msg.value` is equal to the price of the listing.

- **Deadline Check**:

  - Check that `block.timestamp` is less than or equal to the listing's deadline.

- **Signature Verification**:
  - Verify that the `_signature` is signed by the listing's owner.

#### Logic

- Retrieve the `Listing` information from storage based on `_listingId`.
- Transfer ether from the buyer to the seller.
- Transfer the ERC721 token from the seller to the buyer.
- Mark the listing as completed (optional, but useful for preventing double purchases).
