// SPDX-License-Identifier: MIT
// OnixCoin ERC721 token implementation
// Version 1.0.0

pragma solidity ^0.8.0;

import "../openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./depends/MinterRole.sol";

contract ORC721 is ERC721, ERC721Enumerable, MinterRole {
    
    // 
    // Base overrides
    // 
    
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal override(ERC721, ERC721Enumerable) {
        
        super._beforeTokenTransfer(from, to, tokenId);
        
    }
    
    function supportsInterface(bytes4 interfaceId)
    public view override(ERC721, ERC721Enumerable)
    returns (bool) {
        
        return super.supportsInterface(interfaceId);
        
    }
    
    // 
    // ERC721URIStorage Import
    //
    
    using Strings for uint256;
    
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;
    
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        
        return super.tokenURI(tokenId);
    }
    
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
        
    }
    
    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        
        super._burn(tokenId);
        
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    
    /**
     * @dev Imported from:
     *      https://github.com/binodnp/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721MetadataMintable.sol
     */
    function mintWithTokenURI(address to, uint256 tokenId, string memory _tokenURI)
    public virtual onlyMinter returns (bool) {
        
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        
        return true;
    }
    
    /**
     * @dev Custom addition to support minting extra tokens w/o URI
     */
    function mint(address to, uint256 tokenId)
    public virtual onlyMinter returns (bool) {
        
        _safeMint(to, tokenId);
        
        return true;
    }
}
