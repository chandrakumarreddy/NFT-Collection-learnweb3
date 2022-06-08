//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    // Whitelist contract instance
    IWhitelist whitelist;
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;
    // max tokens
    uint8 public maxTokenIds = 20;
    // total number of tokenIds minted
    uint8 public tokenIds;
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;
    // boolean to keep track of whether presale started or not
    bool public presaleStarted;
    //  _price is the price of one Crypto Dev NFT
    uint256 public _price = 0.01 ether;
    // timestamp for when presale would end
    uint256 public presaleEndsAt;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Crypto Devs", "CD")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    //  startPresale starts a presale for the whitelisted addresses
    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEndsAt = block.timestamp + 5 minutes;
    }

    // allows a user to mint one NFT per transaction during the presale.
    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEndsAt,
            "Presale is not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "You are not whitelisted"
        );
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    // allows a user to mint 1 NFT per transaction after the presale has ended.
    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp >= presaleEndsAt,
            "Presale has not ended yet"
        );
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**  _baseURI overides the Openzeppelin's ERC721 implementation which by default
    returned an empty string for the baseURI  */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    // make the contract paused or unpaused
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    // withdraw sends all the ether in the contract to the owner of the contract
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}
