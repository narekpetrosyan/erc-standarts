// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ERC721.sol";

abstract contract ERC721URIStorage is ERC721 {
    mapping(uint => string) _tokenURIs;

    function tokenURI(
        uint _tokenId
    )
        public
        view
        virtual
        override
        _requireMinted(_tokenId)
        returns (string memory)
    {
        string memory _tokenURI = _tokenURIs[_tokenId];
        string memory _base = _baseURI();

        if (bytes(_base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return abi.encodePacked(_base, _tokenURI);
        }

        return super.tokenURI(_tokenId);
    }

    function _setTokenURI(
        uint _tokenId,
        string memory _tokenURI
    ) internal virtual _requireMinted(_tokenId) {
        _tokenURIs[_tokenId] = _tokenURI;
    }

    function burn(uint _tokenId) public override {
        super.burn(_tokenId);
        if (bytes(_tokenURIs[_tokenId]).length != 0) {
            delete _tokenURIs[_tokenId];
        }
    }
}
