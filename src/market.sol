// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract Marketplace {

    struct Item {
        uint id;
        address payable seller;
        string name;
        uint price;
        bool isSold;
        address payable buyer;
    }

    uint public itemCount;
    mapping(uint => Item) public itemsuint; 
    mapping(address => uint[]) public userPurchasedItems;

    event ItemListed(uint indexed id, address indexed seller, string name, uint price);
    event ItemPurchased(uint indexed id, address indexed buyer);

    function listItem(string calldata name, uint price) external {
        require(price > 0, "Price must be greater than zero");

        itemCount++;
        itemsuint[itemCount] = Item({
            id: itemCount,
            seller: payable(msg.sender),
            name: name,
            price: price,
            isSold: false,
            buyer: payable(address(0))
        });

        emit ItemListed(itemCount, msg.sender, name, price);
    }

    function purchaseItem(uint itemId) external payable {
        Item storage item = itemsuint[itemId];

        require(item.id != 0, "Item does not exist");
        require(!item.isSold, "Item already sold");
        require(msg.value == item.price, "Incorrect price");
        require(msg.sender != item.seller, "Seller cannot buy their own item");

        item.isSold = true;
        item.buyer = payable(msg.sender);
        item.seller.transfer(msg.value);

        userPurchasedItems[msg.sender].push(itemId);

        emit ItemPurchased(itemId, msg.sender);
    }

    function getItem(uint itemId) external view returns (uint, address, string memory, uint, bool, address) {
        Item storage item = itemsuint[itemId];
        return (item.id, item.seller, item.name, item.price, item.isSold, item.buyer);
    }

    function getUserPurchasedItems(address user) external view returns (uint[] memory) {
        return userPurchasedItems[user];
    }
}
