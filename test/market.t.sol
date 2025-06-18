// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Marketplace} from "../src/market.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    address public seller;
    address public buyer;

    function setUp() public {
        seller = address(1);
        buyer = address(2);
        vm.deal(seller, 5 ether);
        vm.deal(buyer, 5 ether);

        marketplace = new Marketplace();
    }

    function testListItem() public {
        vm.prank(seller);
        marketplace.listItem("Book", 1 ether);


        (uint id ,address seller, string memory name, uint price, bool isSold, address buyer) = marketplace.getItem(1);
        assertEq(id, 1);
        assertEq(name, "Book");
        assertEq(price, 1 ether);
        assertEq(isSold, false);
    }


    function testPurchaseItem() public {
        vm.prank(seller);
        marketplace.listItem("Laptop", 2 ether);

        vm.prank(buyer);
        marketplace.purchaseItem{value: 2 ether}(1);

        (, address buyerAddr, , , , bool isSold) = marketplace.getItem(1);
        assertEq(buyerAddr, buyer);
        assertTrue(isSold);
    }

    function testFailPurchaseWithWrongAmount() public {
        vm.prank(seller);
        marketplace.listItem("Phone", 1 ether);

        vm.prank(buyer);
        marketplace.purchaseItem{value: 0.5 ether}(1);
    }

    function testUserPurchasesMapping() public {
        vm.prank(seller);
        marketplace.listItem("Camera", 1 ether);

        vm.prank(buyer);
        marketplace.purchaseItem{value: 1 ether}(1);

        uint[] memory purchases = marketplace.getUserPurchases(buyer);
        assertEq(purchases.length, 1);
        assertEq(purchases[0], 1);
    }

    function testWithdrawFunction() public {
        // Sending ETH directly to the contract
        vm.deal(address(this), 1 ether);
        payable(address(marketplace)).transfer(1 ether);

        uint balanceBefore = address(this).balance;
        marketplace.withdraw();
        uint balanceAfter = address(this).balance;

        assertGt(balanceAfter, balanceBefore);
    }
}
