// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// import "hardhat/console.sol";

contract AssessmentNFT is ERC1155Pausable, Ownable {
    using Strings for uint256;

    string private _baseURI;

    /**
     * @dev Emitted when base URI set.
     */
    event BaseURI(string value);

    constructor(string memory baseURI) ERC1155(baseURI) {
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
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external onlyOwner {
        _mint(to, id, amount, data);
    }

    /**
     * @dev Batch operation of mint.
     * See {ERC1155-_mintBatch}.
     * Requirements:
     * - the caller must have the owner.
     */
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function burn(
        uint256 id,
        uint256 value
    ) external {
        _burn(_msgSender(), id, value);
    }

    function burnBatch(
        uint256[] memory ids,
        uint256[] memory values
    ) external {
        _burnBatch(_msgSender(), ids, values);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burn(account, id, value);
    }
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );

        _burnBatch(account, ids, values);
    }

    // TODO: Bonding Curve
}

