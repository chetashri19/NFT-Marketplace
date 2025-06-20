// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    constructor(address initialOwner) Ownable(initialOwner) {}

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        uint price;
        bool sold;
    }

    mapping(uint => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        uint price,
        bool sold
    );

    function listItem(
        address nftContract,
        uint tokenId,
        uint price
    ) public {
        require(price > 0, "Price must be at least 1 wei");

        _itemIds.increment();
        uint itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            price,
            false
        );
    }

    function buyItem(address nftContract, uint itemId) public payable {
        MarketItem storage item = idToMarketItem[itemId];
        require(msg.value == item.price, "Submit the asking price");
        require(!item.sold, "Item already sold");

        item.seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, item.tokenId);
        item.sold = true;
        _itemsSold.increment();
    }

    function fetchUnsoldItems() public view returns (MarketItem[] memory) {
        uint total = _itemIds.current();
        uint unsoldCount = total - _itemsSold.current();
        MarketItem[] memory items = new MarketItem[](unsoldCount);
        uint index = 0;

        for (uint i = 1; i <= total; i++) {
            if (!idToMarketItem[i].sold) {
                items[index] = idToMarketItem[i];
                index++;
            }
        }
        return items;
    }
}
