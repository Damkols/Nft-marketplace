// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Marketplace} from "../src/Marketplace.sol";
import "../src/ERC721Mock.sol";
import "./Helpers.sol";

contract MarketPlaceTest is Helpers {
  Marketplace mPlace;
  OurNFT nft;

  uint256 currentOrderId;

  address addrA;
  address addrB;

  uint256 privKeyA;
  uint256 privKeyB;

  Marketplace.Order order;

  function setUp() public {
    mPlace = new Marketplace();
    nft = new OurNFT();

    (addrA, privKeyA) = mkaddr("USERA");
    (addrB, privKeyB) = mkaddr("USERB");

    order = Marketplace.Order({
      token: address(nft),
      tokenId: 1,
      price: 1 ether,
      signature: bytes(""),
      deadline: 0,
      owner: address(0),
      active: false
    });

    nft.mint(addrA, 1);
  }

  function testOwnerCannotCreateOrder() public {
    order.owner = addrB;
    switchSigner(addrB);

    vm.expectRevert(Marketplace.NotOwner.selector);
    mPlace.createOrder(order);
  }

  function testNFTNotApproved() public {
    switchSigner(addrA);

    vm.expectRevert(Marketplace.NotApproved.selector);
    mPlace.createOrder(order);
  }

  function testMinPriceTooLow() public {
    switchSigner(addrA);
    nft.setApprovalForAll(address(mPlace), true);
    order.price = 0;

    vm.expectRevert(Marketplace.MinPriceTooLow.selector);
    mPlace.createOrder(order);
  }

  function testMinDeadline() public {
    switchSigner(addrA);
    nft.setApprovalForAll(address(mPlace), true);

    vm.expectRevert(Marketplace.DeadlineTooSoon.selector);
    mPlace.createOrder(order);
  }

  function testMinDuration() public {
    switchSigner(addrA);
    nft.setApprovalForAll(address(mPlace), true);
    order.deadline = uint88(block.timestamp + 59 minutes);

    vm.expectRevert(Marketplace.MinDurationNotMet.selector);
    mPlace.createOrder(order);
  }

  function testSignatureNotValid() public {
    switchSigner(addrA);
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
    switchSigner(addrA);

    vm.expectRevert(Marketplace.OrderNotExistent.selector);
    mPlace.editOrder(1, 0, false);
  }

  function testEditOrderNotOwner() public {
    switchSigner(addrA);
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

    // // switchSigner(addrB);

    // vm.expectRevert(Marketplace.NotOwner.selector);
    // mPlace.edit
  }
