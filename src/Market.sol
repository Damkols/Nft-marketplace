// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Market {
    struct Order {
        address orderCreator;
        address tokenAddress;
        uint tokenID;
        uint price;
        bytes32 sign;
        uint deadline;
    }

    uint public listingId;

    mapping(uint => Order) orderMapping;

    function createListing(address _tokenAddress, uint _tokenID, uint _price, bytes32 _sign, uint _deadline) external {
        require(_price > 0, "Price must be greater than zero");
        require(_deadline > block.timestamp, "Add more time");
        Order storage order = orderMapping[listingId];
        order.orderCreator = msg.sender;
        order.tokenAddress = _tokenAddress;
        order.tokenID = _tokenID;
        order.price = _price;
        order.sign = _sign;
        order.deadline = _deadline;
    }



    // function setNumber(uint256 newNumber) public {
    //     number = newNumber;
    // }

    // function increment() public {
    //     number++;
    // }
}
