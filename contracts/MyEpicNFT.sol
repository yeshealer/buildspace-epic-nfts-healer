// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Fantastic", "Epic", "Terrible", "Crazy", "Wild", "Terrifying", "Spooky", "Shameless", "Strange", "Painful", "Clever", "Beautiful"];
    string[] secondWords = ["CupCake", "Pizza", "Milkshake", "Curry", "Chicken", "Sandwich", "Salad", "Apple", "Banana", "Pineapple", "Pear", "Peach"];
    string[] thirdWords = ["Naruto", "Sasuke", "Sakura", "Goku", "Lee", "Gaara", "Minato", "Kakashi", "Madara", "Orochimaru", "Itachi", "Konohamaru"];

    string[] colors = ["red", "#08C2A8", "black", "yellow", "blue", "green", "brown", "aqua"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("yeshealerNFT", "YESHEALER") {
        console.log("This is my NFT contract. Whoa!");
    }

    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        rand = (rand + block.difficulty * 2 + block.timestamp) % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = (rand + block.difficulty * 3 + block.timestamp * 2) % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = (rand + block.difficulty * 4 + block.timestamp * 3) % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
        rand = (rand + block.difficulty * 5 + block.timestamp * 4) % colors.length;
        return colors[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeAnEpicNFT() public {
        uint256 newItemId = _tokenIds.current();

        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combineWord = string(abi.encodePacked(first, second, third));

        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combineWord, "</text></svg>"));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combineWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n---------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("---------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}