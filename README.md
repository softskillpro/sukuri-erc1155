# Sukuri Test ERC-1155 Project

Create an ERC-1155 NFT using OpenZeppelin's ERC-1155 and other libraries.
https://gist.github.com/M4cs/b57fb97a9c9771feff433811e4755674

It should adhere to the following requirements:
- Uses OpenZeppelin ERC-1155 as a base
- Inherits from Ownable and implements proper security for writing to the contract
- Includes the following getters:
  - tokenURI(uint256 tokenId) public view returns (string)
  - contractURI() public view returns (string)
- Implements IERC1155MetadataURI
- Includes bonding curve for mint price with the following variables:
  - Starting price: 0.001 ETH
  - Max price:      0.5 ETH
  - Curve rate:     0.0001 ETH per Mint
  - Decay rate:     0.00005 ETH per Hour # Should decay 0.0005 ETH every hour
- Implements functionality to allow the owner to set a base URI for metadata
- Implements a mechanism to pause/resume the minting process by the owner
- Adds a getter for the current minting price
- Implements a way for users to burn tokens from a user's own account. Should emit an event Burn(from, tokenId)
- (Optional)
  - Implements a way to stake ERC20 tokens to earn NFTs as rewards
  - Implements a function to allow users to set an approved operator to manage their NFTs on their behalf

Try running some of the following tasks:

```shell
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
