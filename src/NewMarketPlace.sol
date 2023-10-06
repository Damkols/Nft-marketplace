// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "openzeppelin/token/ERC721/IERC721.sol";
// import "openzeppelin/access/Ownable.sol";
// import "openzeppelin/utils/math/SafeMath.sol";


// contract Marketplace is Ownable {
//     using SafeMath for uint256;

//     // Struct to represent an NFT order
//     struct Order {
//         address token;
//         uint256 tokenId;
//         uint256 price;
//         uint88 deadline;
//         address owner;
//         bool active;
//     }

//     // Mapping to store orders by order ID
//     mapping(uint256 => Order) public orders;
//     uint256 public orderId = 0;

//     // Events to track order actions
//     event OrderCreated(uint256 indexed orderId, Order order);
//     event OrderExecuted(uint256 indexed orderId, Order order);
//     event OrderEdited(uint256 indexed orderId, Order order);

//     // Modifiers
//     modifier onlyNFTOwner(address token, uint256 tokenId) {
//         require(IERC721(token).ownerOf(tokenId) == msg.sender, "Not the NFT owner");
//         _;
//     }

//     modifier onlyActiveOrder(uint256 _orderId) {
//         require(orders[_orderId].active, "Order is not active");
//         _;
//     }

//     modifier orderExists(uint256 _orderId) {
//         require(_orderId < orderId, "Order does not exist");
//         _;
//     }

//     modifier validPrice(uint256 price) {
//         require(price >= 0.01 ether, "Minimum price not met");
//         _;
//     }

//     modifier validDuration(uint88 deadline) {
//         require(deadline >= block.timestamp.add(60 minutes), "Minimum duration not met");
//         _;
//     }

//     modifier validSignature(
//         address token,
//         uint256 tokenId,
//         uint256 price,
//         uint88 deadline,
//         address owner,
//         bytes memory signature
//     ) {
//         require(
//             isValidSignature(token, tokenId, price, deadline, owner, signature),
//             "Invalid signature"
//         );
//         _;
//     }

//     // Create a new NFT order
//     function createOrder(
//         address token,
//         uint256 tokenId,
//         uint256 price,
//         uint88 deadline,
//         bytes memory signature
//     ) public
//         onlyNFTOwner(token, tokenId)
//         onlyActiveOrder(orderId)
//         validPrice(price)
//         validDuration(deadline)
//         validSignature(token, tokenId, price, deadline, msg.sender, signature)
//     {
//         orders[orderId] = Order({
//             token: token,
//             tokenId: tokenId,
//             price: price,
//             deadline: deadline,
//             owner: msg.sender,
//             active: true
//         });

//         emit OrderCreated(orderId, orders[orderId]);
//         orderId++;
//     }

//     // Execute an NFT order
//     function executeOrder(uint256 _orderId) public payable
//         orderExists(_orderId)
//         onlyActiveOrder(_orderId)
//     {
//         Order storage order = orders[_orderId];
//         require(order.deadline >= block.timestamp, "Order has expired");
//         require(msg.value >= order.price, "Insufficient funds");

//         order.active = false;

//         IERC721(order.token).transferFrom(order.owner, msg.sender, order.tokenId);
//         payable(order.owner).transfer(order.price);

//         emit OrderExecuted(_orderId, order);
//     }

//     // Edit an existing NFT order
//    // Edit an existing NFT order
//     function editOrder(
//         uint256 _orderId,
//         uint256 _newPrice,
//         bool _active
//     ) public
//         onlyNFTOwner(orders[_orderId].token, orders[_orderId].tokenId)
//         orderExists(_orderId)
//     {
//         Order storage order = orders[_orderId];
//         order.price = _newPrice;
//         order.active = _active;

//         emit OrderEdited(_orderId, order);
//     }


//     // Check if a signature is valid
//     function isValidSignature(
//         address token,
//         uint256 tokenId,
//         uint256 price,
//         uint88 deadline,
//         address owner,
//         bytes memory signature
//     ) internal view returns (bool) {
//         // Implement your signature verification logic here
//         // Example: return true if signature is valid, otherwise false
//         return true;
//     }

//     // Get details of an NFT order
//     function getOrder(uint256 _orderId) public view
//         orderExists(_orderId)
//         returns (Order memory)
//     {
//         return orders[_orderId];
//     }
// }
