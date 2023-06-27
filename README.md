## Polygon-NFT-with-metatx-and-ContextMixin
A smart contract for an NFT collection, implementing metatransactions and ContextMixin

## TL;DR
The MyNFT contract is a robust and flexible framework for creating, managing, and trading non-fungible tokens (NFTs) on the Ethereum blockchain. It leverages the OpenZeppelin library to implement standards-compliant NFTs and includes additional features such as role-based access control, royalty payments, and meta-transactions. However, it currently lacks upgradability and may require further optimization for gas efficiency, and is not finished testing. While ERC2771Context is implemented, metatransactions require a trusted forwarder that is beyond the scope of this project. It compiles without warnings and errors in solidity compiler 0.8.19+commit.7dd6d404

## MyNFT
MyNFT is a smart contract for creating, managing, and trading non-fungible tokens (NFTs) on the Ethereum blockchain. It is built using Solidity and the OpenZeppelin library, and it includes features such as role-based access control, royalty payments, and meta-transactions.

## Features
# Role-Based Access Control
The contract uses the AccessControl contract from OpenZeppelin to manage access to certain functions. There are two roles: MINTER_ROLE and OWNER_ROLE. The address that deploys the contract is automatically assigned both roles.

# Royalty Payments
The contract uses the ERC721Royalty extension from OpenZeppelin to implement royalty payments. This allows the original creator of an NFT to receive a percentage of the sale price every time the NFT is sold.

# Meta-Transactions
The contract includes support for meta-transactions, which allow transactions to be signed and then sent by another address. This can be used to pay for gas fees on behalf of users, improving user experience.

# OpenSea Compatibility
The contract includes several features to ensure compatibility with the OpenSea marketplace. This includes automatically approving OpenSea's proxy contracts and providing a contract URI for metadata.
## NOTE: the OpenSea proxy addresses remain to be double-checked and tested!

## Functions
# safeMint(address to, uint256 tokenId, string memory safeTokenURI)
This function allows an address with the MINTER_ROLE to mint a new NFT. The to parameter is the address that will receive the minted token, tokenId is the unique identifier for the token, and safeTokenURI is the URI for the token's metadata.

# setContractURI(string memory newContractURI)
This function allows an address with the OWNER_ROLE to set the contract URI. The newContractURI parameter is the new URI for the contract.

# setRoyaltyRecipient(address newRoyaltyRecipient)
This function allows an address with the OWNER_ROLE to set the recipient of royalty payments. The newRoyaltyRecipient parameter is the address that will receive royalties.

# setRoyaltyBasisPoints(uint256 newRoyaltyBasisPoints)
This function allows an address with the OWNER_ROLE to set the royalty basis points. The newRoyaltyBasisPoints parameter is the new royalty basis points, which represent the percentage of the sale price that will be paid as royalties.

# executeMetaTransaction(address userAddress, bytes memory functionSignature, bytes32 sigR, bytes32 sigS, uint8 sigV)
This function allows a meta-transaction to be executed. The userAddress parameter is the address that is signing the transaction, functionSignature is the signature of the function to be called, and sigR, sigS, and sigV are the components of the signature for the transaction.

## Events
# Mint(address indexed to, uint256 tokenId, string uri)
This event is emitted when a new token is minted. The to parameter is the address that received the token, tokenId is the unique identifier for the token, and uri is the URI for the token's metadata.

# ContractURILocked(string contractURI)
This event is emitted when the contract URI is locked. The contractURI parameter is the URI that was locked.

# RoyaltyRecipientChanged(address indexed newRoyaltyRecipient)
This event is emitted when the royalty recipient is changed. The newRoyaltyRecipient parameter is the address that will receive royalties.

# RoyaltyBasisPointsChanged(uint256 royaltyBasisPoints)
This event is emitted when the royalty basis points are changed. The royaltyBasisPoints parameter is the new royalty basis points.

# MetaTransactionExecuted(address userAddress, address payable relayerAddress, bytes functionSignature)
This event is

## Dependencies

# OpenZeppelin Contracts
The contract uses several contracts from the OpenZeppelin library, including ERC721, ERC721URIStorage, ERC721Royalty, AccessControl, and ERC2771Context. These contracts provide the basic functionality for creating and managing NFTs, role-based access control, and handling meta-transactions.

# ContextMixin
This is a custom contract used to handle context in the contract. It is an upgraded version of the original published code on OpenSea to comply with standards necessary in Solidity 0.8.19.

# Setup
To deploy the contract, you will need to provide the name and symbol for the NFT, as well as the address of a trusted forwarder for handling meta-transactions.

# Security
The contract includes several security features, such as role-based access control and checks to prevent replay attacks.

## Contract Code
The contract code is provided in Solidity. It includes several functions for managing NFTs, such as minting new tokens, setting the contract URI, setting the royalty recipient, and executing meta-transactions. It also includes several events that are emitted when certain actions are performed, such as minting a new token, locking the contract URI, changing the royalty recipient, and executing a meta-transaction. The contract uses several contracts from the OpenZeppelin library, as well as a custom contract called ContextMixin.

The contract code is commented extensively to explain what each function and event does. It includes several checks to ensure that only authorized addresses can perform certain actions, and to prevent replay attacks in meta-transactions. The contract code is designed wo we hope it will be secure, efficient, and easy to understand.

## Detailed Function Descriptions
# safeMint
This function allows an address with the MINTER_ROLE to mint a new NFT. It takes three parameters: the recipient's address (to), the unique identifier for the token (tokenId), and the URI for the token's metadata (safeTokenURI). The function checks that the caller has the MINTER_ROLE and that the tokenId is within the allowed range for the caller. It then mints the token, sets its URI, and emits a Mint event.

# setContractURI
This function allows an address with the OWNER_ROLE to set the contract URI. The contract URI is a string that points to a JSON file with metadata about the entire collection of NFTs. The function checks that the caller has the OWNER_ROLE and that the contract URI has not been locked. It then sets the contract URI to the provided string.

# setRoyaltyRecipient
This function allows an address with the OWNER_ROLE to set the recipient of royalty payments. The royalty recipient is the address that will receive a percentage of the sale price every time an NFT is sold. The function checks that the caller has the OWNER_ROLE and that the provided address is not the zero address. It then sets the royalty recipient to the provided address and emits a RoyaltyRecipientChanged event.

# setRoyaltyBasisPoints
This function allows an address with the OWNER_ROLE to set the royalty basis points. The royalty basis points represent the percentage of the sale price that will be paid as royalties. The function checks that the caller has the OWNER_ROLE and that the provided value is less than or equal to 10000 (representing 100%). It then sets the royalty basis points to the provided value and emits a RoyaltyBasisPointsChanged event.

# executeMetaTransaction
This function allows a meta-transaction to be executed. A meta-transaction is a transaction that is signed by one address and sent by another address. This can be used to pay for gas fees on behalf of users. The function takes five parameters: the address that is signing the transaction (userAddress), the signature of the function to be called (functionSignature), and the components of the signature for the transaction (sigR, sigS, and sigV). The function checks that the provided address is not the zero address and that the signer matches the recovered address from the signature. It then increments the nonce for the user address, emits a MetaTransactionExecuted event, and calls the function with the provided signature.

## Detailed Event Descriptions
# Mint
This event is emitted when a new token is minted. It includes the address that received the token (to), the unique identifier for the token (tokenId), and the URI for the token's metadata (uri).

# ContractURILocked
This event is emitted when the contract URI is locked. Once the contract URI is locked, it cannot be changed. The event includes the URI that was locked (contractURI).

# RoyaltyRecipientChanged
This event is emitted when the royalty recipient is changed. It includes the new royalty recipient's address (newRoyaltyRecipient).

# RoyaltyBasisPointsChanged
This event is emitted when the royalty basis points are changed. It includes the new royalty basis points (royaltyBasisPoints).

# MetaTransactionExecuted
This event is emitted when a meta-transaction is executed. It includes the address that signed the transaction (userAddress), the address that sent the transaction (relayerAddress), and the signature of the function that was called (functionSignature).

## Conclusion
The MyNFT contract provides a robust and flexible framework for creating, managing, and trading NFTs on the Ethereum blockchain. It leveragesthe OpenZeppelin library to implement standards-compliant NFTs and includes additional features such as role-based access control, royalty payments, and meta-transactions. The contract is designed to be secure, efficient, and easy to use, with clear comments explaining the purpose and functionality of each part of the code.

## Additional Notes
# Role-Based Access Control
The contract uses the AccessControl contract from OpenZeppelin to manage access to certain functions. There are two roles: MINTER_ROLE and OWNER_ROLE. The address that deploys the contract is automatically assigned both roles. This allows the contract owner to control who can mint new tokens and change important settings.

# Royalty Payments
The contract uses the ERC721Royalty extension from OpenZeppelin to implement royalty payments. This allows the original creator of an NFT to receive a percentage of the sale price every time the NFT is sold. The percentage is set using the setRoyaltyBasisPoints function, and the recipient is set using the setRoyaltyRecipient function. Note that this is not an on-chain compulsory calculation of royalties. However, we believe at the present this standard is simplest and will be the overall best choice for most.

# Meta-Transactions
The contract includes support for meta-transactions, which allow transactions to be signed and then sent by another address. This can be used to pay for gas fees on behalf of users, improving user experience. The executeMetaTransaction function is used to execute meta-transactions.

# OpenSea Compatibility
The contract includes several features to ensure compatibility with the OpenSea marketplace. This includes automatically approving OpenSea's proxy contracts and providing a contract URI for metadata. The contract URI is set using the setContractURI function and locked using the lockContractURI function.

# Minting Range
The contract allows the contract owner to grant the MINTER_ROLE to other addresses within a specified token ID range. This is done using the grantMinterRole function. The minting range for each minter is stored in the _minterRanges mapping.

# Chain ID
The contract includes a getChainId function that returns the current chain ID. This is used to whitelist OpenSea's proxy contracts on different networks.  Note that OpenSea's proxy contracts are not at the present double-checked or tested.

# Domain Separator
The contract includes a getDomainSeparator function that returns the EIP-712 domain separator. This is used in the signing and verification of meta-transactions.

## Security Considerations
The MyNFT contract includes several security features to protect against common attack vectors:

# Role-Based Access Control
The contract uses the AccessControl contract from OpenZeppelin to manage access to certain functions. This ensures that only addresses with the appropriate roles can perform sensitive actions such as minting new tokens or changing the contract settings. The contract owner can grant and revoke roles as needed.

# Nonces
The contract uses nonces to prevent replay attacks in meta-transactions. Each user has a nonce that is incremented every time they execute a meta-transaction. This ensures that each meta-transaction can only be executed once. The nonce for each user is stored in the _nonces mapping.

# Checks
The contract includes various checks to ensure that operations are performed correctly. For example, it checks that the tokenId is within the allowed range when minting a new token, and it checks that the newRoyaltyBasisPoints is less than or equal to 10000 when setting the royalty basis points.

# Overrides
The contract overrides several functions from its parent contracts to ensure correct behavior. For example, it overrides the supportsInterface function to correctly handle multiple inheritance, and it overrides the _burn and tokenURI functions to use the ERC721URIStorage extension.

## Limitations and Future Work
While the MyNFT contract provides a robust and flexible framework for creating, managing, and trading NFTs, there are some limitations and areas for future work:

# Customization
The contract is designed to be generic and flexible, but some projects may require more customization. For example, a project may want to implement a different royalty system, add additional roles, or include other features such as token locking or batch minting.

# Upgradability
The contract does not currently support upgradability. This means that once the contract is deployed, its code cannot be changed. If a bug is found or if the contract needs to be updated to support new features or standards, a new contract would need to be deployed and the existing tokens would need to be migrated.

# Gas Efficiency
While the contract includes several features to improve user experience, such as meta-transactions and automatic approval of OpenSea's proxy contracts, these features may increase gas costs. Future work could explore ways to optimize the contract to reduce gas costs.

# Testing
While the contract has been carefully designed and reviewed, it has not yet been thoroughly tested.  It compiles without warnings and errors in solidity compiler 0.8.19+commit.7dd6d404
