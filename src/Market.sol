// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "openzeppelin/token/ERC721/IERC721.sol";
import "openzeppelin/token/ERC721/extensions/IERC721Enumerable.sol";
import "openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";
import "openzeppelin/utils/math/SafeMath.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/cryptography/ECDSA.sol";


 struct Order {
        uint listingId;
        address orderCreator;
        address tokenAddress;
        uint tokenID;
        uint price;
        bytes signature;
        uint deadline;
        bool isSold;
    }

contract Market is Ownable {
    using ECDSA for bytes32;


    uint public listingId;

    mapping(uint => Order) _orderMapping;

        constructor() {}

     event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        address indexed tokenAddress,
        uint256 tokenID,
        uint256 price,
        uint256 deadline
    );

    event ListingSold(uint256 indexed listingId,  address indexed seller);


    function createListing(address _tokenAddress, uint _tokenID, uint _price, bytes memory _signature, uint _deadline) external {
        bytes32 orderId = keccak256(abi.encodePacked(msg.sender, _tokenAddress, _tokenID, _price, _deadline));
        require(_validateSignature(orderId, _signature, msg.sender), "Invalid signature");
        require(_tokenAddress != address(0), "Invalid token address");
        require(_price > 0, "Price must be greater than zero");
        require(_deadline > block.timestamp, "Deadline must be in the future");
        IERC721 token = IERC721(_tokenAddress);
        token.approve(_tokenAddress, _tokenID);
        require(token.ownerOf(_tokenID) == msg.sender, "You are not the owner");
        require(
            token.isApprovedForAll(msg.sender, address(this)),
            "You must approve the contract to manage your NFT"
        );

        listingId++;
        _orderMapping[listingId] = Order({
        listingId: listingId,
        orderCreator: msg.sender,
        tokenAddress: _tokenAddress,
        tokenID: _tokenID,
        price: _price,
        signature: _signature,
        deadline: _deadline,
        isSold: false
        });

        emit ListingCreated(listingId, msg.sender, _tokenAddress, _tokenID, _price, _deadline);

        // Order storage order = orderMapping[listingId];
        // order.orderCreator = msg.sender;
        // order.tokenAddress = _tokenAddress;
        // order.tokenID = _tokenID;
        // order.price = _price;
        // order.sign = _sign;
        // order.deadline = _deadline;
    }


 function executeListing(bytes32 orderId, uint256 _listingId, bytes memory _signature) external payable {
        require(_listingId <= listingId, "Invalid listing ID");
        Order storage order = _orderMapping[_listingId];
        require(!order.isSold, "Listing is already sold");
        require(msg.value == order.price, "Incorrect payment amount");
        require(block.timestamp <= order.deadline, "Listing has expired");
        require(_validateSignature(orderId, _signature, msg.sender), "Invalid signature");

        IERC721 token = IERC721(order.tokenAddress);
        require(token.ownerOf(order.tokenID) == order.orderCreator, "Seller no longer owns the NFT");

        order.isSold = true;
        token.safeTransferFrom(order.orderCreator, msg.sender, order.tokenID);
        payable(order.orderCreator).transfer(msg.value);

        emit ListingSold(_listingId, msg.sender);
    }

    function _validateSignature(bytes32 orderId, bytes memory _signature, address expectedSigner) internal pure returns (bool) {
        bytes32 hash = ECDSA.toEthSignedMessageHash(orderId);
        address signer = ECDSA.recover(hash, _signature);
        return signer == expectedSigner;
    }
}
