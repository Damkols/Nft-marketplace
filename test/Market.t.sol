// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Marketplace} from "../src/Marketplace.sol";
import "../src/ERC721Mock.sol";
import "./Helpers.sol";

contract MarketPlaceTest is Helpers {
  Marketplace mPlace;
  OurNFT nft;

  uint256 currentOrderId;

  address userA;
  address userB;

  uint256 privKeyA;
  uint256 privKeyB;

  Marketplace.Order order;

  function setUp() public {
    mPlace = new Marketplace();
    nft = new OurNFT();

    (userA, privKeyA) = mkaddr("USERA");
    (userB, privKeyB) = mkaddr("USERB");

    order = Marketplace.Order({
      token: address(nft),
      tokenId: 1,
      price: 1 ether,
      signature: bytes(""),
      deadline: 0,
      owner: address(0),
      active: false
    });

    nft.mint(userA, 1);
  }

  function testOwnerCannotCreateOrder() public {
    order.owner = userB;
    switchSigner(userB);

    vm.expectRevert(Marketplace.NotOwner.selector);
    mPlace.createOrder(order);
  }

  function testNFTNotApproved() public {
    switchSigner(userA);

    vm.expectRevert(Marketplace.NotApproved.selector);
    mPlace.createOrder(order);
  }

  function testMinPriceTooLow() public {
    switchSigner(userA);
    nft.setApprovalForAll(address(mPlace), true);
    order.price = 0;

    vm.expectRevert(Marketplace.MinPriceTooLow.selector);
    mPlace.createOrder(order);
  }

  function testMinDeadline() public {
    switchSigner(userA);
    nft.setApprovalForAll(address(mPlace), true);

    vm.expectRevert(Marketplace.DeadlineTooSoon.selector);
    mPlace.createOrder(order);
  }

  function testMinDuration() public {
    switchSigner(userA);
    nft.setApprovalForAll(address(mPlace), true);
    order.deadline = uint88(block.timestamp + 59 minutes);

    vm.expectRevert(Marketplace.MinDurationNotMet.selector);
    mPlace.createOrder(order);
  }

  function testSignatureNotValid() public {
    switchSigner(userA);
    nft.setApprovalForAll(address(mPlace), true);
    order.deadline = uint88(block.timestamp + 120 minutes);
    order.signature = constructSig(
      order.token,
      order.tokenId,
      order.price,
      order.deadline,
      order.owner,
      privKeyB
    );

    vm.expectRevert(Marketplace.InvalidSignature.selector);
    mPlace.createOrder(order);
  }

  function testEditNonValidOrder() public {
    switchSigner(userA);

    vm.expectRevert(Marketplace.OrderNotExistent.selector);
    mPlace.editOrder(1, 0, false);
  }

  function testEditOrderNotOwner() public {
    switchSigner(userA);
    nft.setApprovalForAll(address(mPlace), true);
    order.deadline = uint88(block.timestamp + 120 minutes);
    order.signature = constructSig(
      order.token,
      order.tokenId,
      order.price,
      order.deadline,
      order.owner,
      privKeyA
    );
  }

    // uint256 newOrderId = mPlace.createOrder(order);

    // // switchSigner(userB);

    // vm.expectRevert(Marketplace.NotOwner.selector);
    // mPlace.edit
  }
