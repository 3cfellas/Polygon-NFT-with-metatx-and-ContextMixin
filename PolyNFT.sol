// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importing necessary OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // Standard for non-fungible tokens
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // Extension for storing URIs per token
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol"; // Extension for royalty payments
import "@openzeppelin/contracts/access/AccessControl.sol"; // Contract module for role-based access control
import "@openzeppelin/contracts/metatx/ERC2771Context.sol"; // Contract module for receiving meta-transactions
import "./ContextMixin.sol"; // Custom contract for handling context

// Contract inherits from multiple OpenZeppelin contracts
contract MyNFT is ERC721, ERC721URIStorage, ERC721Royalty, AccessControl, ERC2771Context, ContextMixin {
    // Define roles for AccessControl
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // Role for minting tokens
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE"); // Role for contract owner

    // Define minting event
    event Mint(address indexed to, uint256 tokenId, string uri); // Event emitted when a new token is minted

    // Define event for locking contractURI
    event ContractURILocked(string contractURI); // Event emitted when the contractURI is locked

    // Define event for changing royalty recipient
    event RoyaltyRecipientChanged(address indexed newRoyaltyRecipient); // Event emitted when the royalty recipient is changed

    // Define minting range structure
    struct MintingRange {
        uint256 minTokenId; // Minimum token ID that can be minted
        uint256 maxTokenId; // Maximum token ID that can be minted
    }

    // Define proxy addresses as variables
    // These are the addresses of the OpenSea proxy contracts on different networks
    address private constant ETHEREUM_PROXY_ADDRESS = 0x58807baD0B376efc12F5AD86aAc70E78ed67deaE;
    address private constant POLYGON_PROXY_ADDRESS = 0x58807baD0B376efc12F5AD86aAc70E78ed67deaE;
    address private constant GOERLI_PROXY_ADDRESS = 0x2545943C4d9f6F4A617cEAbA91bd13eD37DeF1aD;
    address private constant MUMBAI_PROXY_ADDRESS = 0x2545943C4d9f6F4A617cEAbA91bd13eD37DeF1aD;

    // Define event for changing royalty basis points
    event RoyaltyBasisPointsChanged(uint256 royaltyBasisPoints); // Event emitted when the royalty basis points are changed

    // Define the EIP-712 typehash for meta-transactions
    bytes32 private constant _META_TRANSACTION_TYPEHASH = keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)");

    // Define a mapping to store nonces for each user
    // Nonces are used to prevent replay attacks in meta-transactions
    mapping(address => uint256) private _nonces;

    // Define an event for executed meta-transactions
    event MetaTransactionExecuted(address userAddress, address payable relayerAddress, bytes functionSignature); // Event emitted when a meta-transaction is executed
    
    // Define royalty basis points
    uint256 private _I apologize for the abrupt cut-off. Here's the continuation of the commented code:

```solidity
    // Define royalty basis points
    uint256 private _royaltyBasisPoints = 500; // 5% royalty rate

    // Map minters to their minting ranges
    mapping(address => MintingRange) private _minterRanges; // Mapping from minter address to their allowed minting range

    // Variable to store contractURI
    string private _contractURI; // URI for the contract metadata

    // Variable to store contractURI lock status
    bool private _contractURILocked = false; // Boolean to indicate whether the contractURI has been locked

    // Define royalty recipient
    address private _royaltyRecipient; // Address to receive royalties

    // Constructor function
    constructor(string memory name, string memory symbol, address trustedForwarder)
    ERC721(name, symbol) // Call to ERC721 constructor
    ERC2771Context(trustedForwarder) // Call to ERC2771Context constructor
    {
        // Grant the contract deployer the MINTER_ROLE and OWNER_ROLE
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(OWNER_ROLE, _msgSender());

        // Set the contract deployer as the initial royalty recipient
        _royaltyRecipient = _msgSender();
    }

    // Override _msgSender() to use ContextMixin
    function _msgSender() internal view override(Context, ERC2771Context) returns (address) {
        return payable(ContextMixin.msgSender()); // Use the msgSender function from the ContextMixin contract
    }

    // Override isApprovedForAll to auto-approve OS's proxy contract
    function isApprovedForAll(address owner, address operator) public view override(ERC721, IERC721) returns (bool) {
        // Whitelist OpenSea proxy contract on relevant chain for easy trading.
        if (getChainId() == 1 && operator == ETHEREUM_PROXY_ADDRESS) {
            return true;
        } else if (getChainId() == 137 && operator == POLYGON_PROXY_ADDRESS) {
            return true;
        } else if (getChainId() == 5 && operator == GOERLI_PROXY_ADDRESS) {
            return true;
        } else if (getChainId() == 80001 && operator == MUMBAI_PROXY_ADDRESS) {
            return true;
        }

        // otherwise, use the default ERC721.isApprovedForAll()
        return super.isApprovedForAll(owner, operator);
    }

    // Grant minter role to a specific address within a specified token ID range
    function grantMinterRole(address minter, uint256 minTokenId, uint256 maxTokenId) public {
        require(hasRole(OWNER_ROLE, _msgSender()), "Caller is not the owner"); // Only the owner can grant the minter role
        require(minter != address(0), "Minter cannot be zero address"); // The minter address cannot be the zero address
        grantRole(MINTER_ROLE, minter); // Grant the minter role to the specified address
        _minterRanges[minter] = MintingRange(minTokenId, maxTokenId); // Set the minting range for the minter
    }

    // Set contractURI
    function setContractURI(string memory newContractURI) public {
        require(hasRole(OWNER_ROLE, _msgSender()), "Caller is not the owner"); // Only the owner can set the contract URI
        require(!_contractURILocked, "Contract URI has been locked"); // The contract URI cannot be set if it has been locked
        _contractURI = newContractURI; // Set the contract URI
    }

    // Lock contractURI
    function lockContractURI() public {
        require(hasRole(OWNER_ROLE, _msgSender()), "Caller is not the owner"); // Only the owner can lock the contract URI
        require(!_contractURILocked, "Contract URI is already locked"); // The contract URI cannot be locked if it is already locked
        _contractURILocked = true; // Lock the contract URI
        emit ContractURILocked(_contractURI); // Emit the ContractURILocked event
    }

    // Get contractURI
    function contractURI() public view returns (string memory) {
        return _contractURI; // Return the contract URI
    }

    // Set royalty recipient
    function setRoyaltyRecipient(address newRoyaltyRecipient) public {
        require(hasRole(OWNER_ROLE, _msgSender()), "Caller is not the owner"); // Only the owner can set the royalty recipient
        require(newRoyaltyRecipient != address(0), "Royalty recipient cannot be zero address"); // The royalty recipient cannot be the zero address
        _royaltyRecipient = newRoyaltyRecipient; // Set the royalty recipient
        emit RoyaltyRecipientChanged(newRoyaltyRecipient); // Emit the RoyaltyRecipientChanged event
    }

    function _msgData() internal view override(Context, ERC2771Context) returns (bytes calldata) {
        return super._msgData(); // Use the _msgData function from the parent contracts
    }

    // Get royalty recipient
    function royaltyRecipient() public view returns (address) {
        return _royaltyRecipient; // Return the royalty recipient
    }

    // Define safe minting function
    function safeMint(address to, uint256 tokenId, string memory safeTokenURI) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to mint"); // Only minters can mint tokens
        require(tokenId >= _minterRanges[_msgSender()].minTokenId && tokenId <= _minterRanges[_msgSender()].maxTokenId, "Token ID is not within the allowed range"); // The token ID must be within the allowed range

        _safeMint(to, tokenId); // Mint the token
        _setTokenURI(tokenId, safeTokenURI); // Set the token URI

        emit Mint(to, tokenId, safeTokenURI); // Emit the Mint event
    }

    // Set royalty basis points
    function setRoyaltyBasisPoints(uint256 newRoyaltyBasisPoints) public {
        require(hasRole(OWNER_ROLE, _msgSender()), "Caller is not the owner"); // Only the owner can set the royalty basis points
        require(newRoyaltyBasisPoints <= 10000, "Royalty basis points must be <= 10000"); // The royalty basis points must be less than or equal to 10000
        _royaltyBasisPoints = newRoyaltyBasisPoints; // Set the royalty basis points
        emit RoyaltyBasisPointsChanged(newRoyaltyBasisPoints); // Emit the RoyaltyBasisPointsChanged event
    }

    // Get royalty basis points
    function royaltyBasisPoints() public view returns (uint256) {
        return _royaltyBasisPoints; // Return the royalty basis points
    }

    // Define royalty functions
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view override returns (address receiver, uint256 royaltyAmount) {
        // Silence the unused variable warning (unused because sameI apologize for the abrupt cut-off again. Here's the continuation of the commented code:

```solidity
        // Silence the unused variable warning (unused because same royalty for all tokens)
        _tokenId;

        // Royalty receiver is the royalty recipient
        receiver = _royaltyRecipient;

        // Calculate royalty amount
        royaltyAmount = (_salePrice * _royaltyBasisPoints) / 10000; // Calculate the royalty amount as a percentage of the sale price

        return (receiver, royaltyAmount); // Return the royalty recipient and the royalty amount
    }

    // Commented out because no logic is meant to be calculated before transfer
    // function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721) {
    //     super._beforeTokenTransfer(from, to, tokenId); // Call the _beforeTokenTransfer function from the parent contract
    // }

    // Override supportsInterface to use multiple inheritance
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, ERC721Royalty, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId); // Call the supportsInterface function from the parent contracts
    }

    // Override _burn to use multiple inheritance
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId); // Call the _burn function from the parent contracts
    }

    // Override tokenURI to use multiple inheritance
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId); // Call the tokenURI function from the parent contracts
    }

    // Meta-transaction functions
    function executeMetaTransaction(address userAddress, bytes memory functionSignature, bytes32 sigR, bytes32 sigS, uint8 sigV) public payable returns(bytes memory) {
        bytes32 signHash = getSignHash(userAddress, functionSignature); // Get the sign hash
        require(userAddress != address(0), "Zero address"); // The user address cannot be the zero address
        require(userAddress == ecrecover(signHash, sigV, sigR, sigS), "Signer and signature do not match"); // The signer must match the recovered address from the signature
                _nonces[userAddress]++; // Increment the nonce for the user address

        emit MetaTransactionExecuted(userAddress, msgSender(), functionSignature); // Emit the MetaTransactionExecuted event

        // Append userAddress at the end to extract it from calling context
        (bool success, bytes memory returnData) = address(this).call(abi.encodePacked(functionSignature, userAddress)); // Call the function with the provided signature
        require(success, "Function call not successful"); // The function call must be successful

        return returnData; // Return the data returned by the function call
    }

    function getNonce(address user) public view returns(uint256) {
        return _nonces[user]; // Return the nonce for the user address
    }

    function getChainId() public view returns (uint256 chainId) {
        assembly {
            chainId := chainid() // Get the chain ID
        }
    }

    function getSignHash(address userAddress, bytes memory functionSignature) internal view returns(bytes32 signHash) {
        uint256 nonce = _nonces[userAddress]; // Get the nonce for the user address
        bytes32 metaTransactionTypeHash = keccak256(abi.encode(_META_TRANSACTION_TYPEHASH, nonce, userAddress, keccak256(functionSignature))); // Get the hash of the meta-transaction type
        signHash = keccak256(abi.encodePacked("\x19\x01", getDomainSeparator(), metaTransactionTypeHash)); // Get the sign hash
    }

    function getDomainSeparator() internal view returns(bytes32 domainSeparator) {
        domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name())),
            keccak256(bytes("1")),
            getChainId(),
            address(this)
        )); // Get the domain separator
    }
}
