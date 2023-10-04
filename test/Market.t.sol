// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import {Test, console2} from "forge-std/Test.sol";


// import {Test} from "lib/forge-std/src/Test.sol";
import {Market, Order} from "../src/Market.sol";


contract MarketTest is Test {
     Market public market;

    function setUp() public {

        market = new Market();

        address seller;
        address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
        uint256 tokenID = 1;
        uint256 price = 2;
        uint256 deadline = 36646456;

        address signer = vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
        deadline = 44445555221;

        vm.startPrank(signer);
        seller = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        bytes32 digest = keccak256(abi.encodePacked(tokenAddress, tokenID, price, deadline));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, digest);
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

         market.createListing(tokenAddress, tokenID, price, signature, block.timestamp + 100);

    }


        function testsetUp() public {
        market = new Market();
        // address _tokenAddress,
        // uint256 _tokenId,
        // uint256 _price,
        // bytes memory _signature,
        // uint256 _deadline
        address seller;
        address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
        uint256 tokenId = 1;
        uint256 price = 5;
        uint256 deadline = 466252191;

        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        seller = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        bytes32 digest = keccak256(
            abi.encodePacked(seller, tokenAddress, tokenId, price,  deadline)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80,
            digest
        );
        bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        vm.stopPrank();

        market.createListing(tokenAddress, tokenId, price, signature, deadline);

    }


    function testCreateListing() public {
        // Arrange
        uint tokenId = 1;
        uint price = 10 ether;

        address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
        uint256 deadline = 466252191;
        (uint8 v, bytes32 r, bytes32 s)= vm.sign(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d, keccak256(abi.encodePacked(msg.sender, tokenAddress, tokenId, price, block.timestamp + 100)));
        bytes memory signature = abi.encodePacked(r, s, v);
        

        // Act
        market.createListing(tokenAddress, tokenId, price, signature, deadline);

        // Assert
        Order memory order;
        assertEq(order.listingId, 1);
        assertEq(order.orderCreator, msg.sender);
        assertEq(order.tokenAddress, tokenAddress);
        assertEq(order.tokenID, tokenId);
        assertEq(order.price, price);
        assertEq(order.signature, signature);
        assertEq(order.deadline, deadline);
        assertEq(order.isSold, false);
    }

    function testExecuteListing() public {
        // Arrange
        address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
        uint tokenId = 1;
        uint price = 10 ether;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, keccak256(abi.encodePacked(msg.sender, tokenAddress, tokenId, price, block.timestamp + 100)));
        bytes memory signature = abi.encodePacked(r, s, v);

        // Create the listing
        market.createListing(tokenAddress, tokenId, price, signature, block.timestamp + 100);

        // Act
        market.executeListing(keccak256(abi.encodePacked(msg.sender, tokenAddress, tokenId, price, block.timestamp + 100)), 1, signature);

        // Assert
        Order memory order;
        assertEq(order.isSold, true);
    }

    function testSignature() public {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        // Computes the address for a given private key.
        address seller = vm.addr(privateKey);

        // Test valid signature
        bytes32 messageHash = keccak256("Signed by seller");

        (uint8 v,bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
        address signer = ecrecover(messageHash, v, r, s);

        assertEq(signer, seller);

        // Test invalid message
        bytes32 invalidHash = keccak256("Not signed by Seller");
        signer = ecrecover(invalidHash, v, r, s);

        assertTrue(signer != seller);
    }
}



// contract CounterTest is Test {
//     Market public market;

//     function testsetUp() public {
//         market = new Market();
//         // address _tokenAddress,
//         // uint256 _tokenId,
//         // uint256 _price,
//         // bytes memory _signature,
//         // uint256 _deadline
//         address seller;
//         address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
//         uint256 tokenId = 1;
//         uint256 price = 5;
//         uint256 deadline = 466252191;

//         vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
//         seller = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
//         bytes32 digest = keccak256(
//             abi.encodePacked(seller, tokenAddress, tokenId, price,  deadline)
//         );
//         (uint8 v, bytes32 r, bytes32 s) = vm.sign(
//             0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80,
//             digest
//         );
//         bytes memory signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
//         vm.stopPrank();

//         market.createListing(tokenAddress, tokenId, price, signature, deadline);

//         // nftMarketPlace.createOrder(
//         //     tokenAddress,
//         //     tokenId,
//         //     price,
//         //     signature,
//         //     deadline
//         // );
//     }

//         function testSignature() public {
//         uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
//         //  address seller;
//         address tokenAddress = 0x25D0e89E6Df7ae8C0E8D1D9Bd0991CbE17d10628;
//         uint256 tokenId = 1;
//         uint256 price = 5;
//         uint256 deadline = 466252191;
//         // Computes the address for a given private key.
//         address seller = vm.addr(privateKey);

//         // Test valid signature
//         bytes32 messageHash = keccak256(
//             abi.encodePacked(seller, tokenAddress, tokenId, price,  deadline)
//         );

//         (uint8 v,bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);
//         bytes memory signature = abi.encodePacked(r, s, v);
//         address signer = ecrecover(messageHash, v, r, s);

//         assertEq(signer, seller);

//         // Test invalid message
//         bytes32 invalidHash = keccak256("Not signed by Seller");
//         signer = ecrecover(invalidHash, v, r, s);

//         market.createListing(tokenAddress, tokenId, price, signature, deadline);

//         assertTrue(signer != seller);
//     }

// }