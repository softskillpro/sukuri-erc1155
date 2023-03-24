// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {BondingCurve} from "./BondingCurve.sol";

contract AssessmentNFT is ERC1155Pausable, Ownable {
    using Strings for uint256;
    using BondingCurve for BondingCurve.Curve;

    string private _baseURI;
    uint256 public reserveBalance;
    uint256 public totalSupply;

    BondingCurve.Curve public curve;

    /**
     * @dev Emitted when base URI set.
     */
    event BaseURI(string value);

    constructor(string memory baseURI) ERC1155(baseURI) {
    curve = BondingCurve.Curve({
    lastUpdate: 0,
    spotPrice: 0,
    curveRate: 0.0001 ether,
    decayRate: 0.00005 ether,
    maxPrice: 0.5 ether,
    minPrice: 0.001 ether
        });
    }

    /**
     * @notice return URI for the contract.
     */
    function contractURI() public view returns (string memory) {
        return _baseURI;
    }

    /**
     * @notice return URI for a given asset.
     */
    function uri(uint256 id) public view override returns (string memory) {
        return string.concat(_baseURI, Strings.toString(id));
    }

    /**
     * @notice set URI for the contract.
     * Requirements:
     * - the caller must have the owner.
     */
    function setURI(string memory newURI) external onlyOwner {
        _setURI(newURI);
    }

    function _setURI(string memory newURI) internal override {
        _baseURI = newURI;
        emit BaseURI(_baseURI);
    }

    /**
     * @notice pause transfer of tokens.
     * See {Pausable-_pause}.
     * Requirements:
     * - the caller must have the owner.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice unpause transfer of tokens.
     * See {Pausable-_unpause}.
     * Requirements:
     * - the caller must have the owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     * See {ERC1155-_mint}.
     * Requirements:
     * - the caller must have the owner.
     */
    function mint(uint256 id, uint256 amount) external payable {
        require(msg.value > 0, "ERC1155: Must send ether to buy tokens.");

        (uint128 newSpotPrice, uint256 totalCost) = curve.getBuyInfo(amount);
        require(msg.value >= totalCost, "ERC1155: Insufficient ETH sent for mint");

        curve.spotPrice = newSpotPrice;
        curve.lastUpdate = block.timestamp;

        // refund any extra ETH sent
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        _mint(_msgSender(), id, amount, new bytes(0));
    }

    function burn(
        uint256 id,
        uint256 amount
    ) external {
        _burn(_msgSender(), id, amount);
    }

    function burnBatch(
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        _burnBatch(_msgSender(), ids, amounts);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) external {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, amount);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, amounts);
    }

    /**
     * @notice get the current price for mint.
     * @return newSpotPrice current price for mint
     */
    function getCurrentMintPrice() external view returns (uint128 newSpotPrice) {
        (newSpotPrice, ) = curve.getBuyInfo(1);
    }

    /**
     * @notice get the cost for mint.
     * @param amount the number of tokens to purchase
     * @return totalCost the amount of purchase tokens to purchase the items
     */
    function getMintCost(uint256 amount) external view returns (uint256 totalCost) {
        (, totalCost) = curve.getBuyInfo(amount);
    }
}

