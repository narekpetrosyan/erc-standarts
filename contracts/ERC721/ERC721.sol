// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "../ERC165/ERC165.sol";
import "../Strings.sol";

abstract contract ERC721 is ERC165, IERC721Metadata {
    string public name;
    string public symbol;

    using Strings for uint;

    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;

    modifier _requireMinted(uint _tokenId) {
        require(_exists(_tokenId), "Not minted");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address _owner) public view returns (uint) {
        require(_owner != address(0), "Zero address");
        return _balances[_owner];
    }

    function ownerOf(
        uint _tokenId
    ) public view _requireMinted(_tokenId) returns (address) {
        return _owners[_tokenId];
    }

    function transferFrom(address _from, address _to, uint _tokenId) external {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "Not an owner or approved"
        );

        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint _tokenId
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "Not an owner or approved"
        );

        _safeTransfer(_from, _to, _tokenId);
    }

    function approve(address _to, uint _tokenId) public {
        address _owner = ownerOf(_tokenId);
        require(
            _owner == msg.sender || isApprovedForAll(_owner, msg.sender),
            "Not an owner"
        );
        require(_to != _owner, "Cannot ");

        _tokenApprovals[_tokenId] = _to;

        emit Approval(_owner, _to, _tokenId);
    }

    function getApproved(
        uint _tokenId
    ) public view _requireMinted(_tokenId) returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function _safeMint(address _to, uint _tokenId) internal virtual {
        _mint(_to, _tokenId);

        require(
            _checkOnERC721Received(msg.sender, _to, _tokenId),
            "Non ERC721 receiver"
        );
    }

    function _mint(address _to, uint _tokenId) internal virtual {
        require(_to != address(0), "_to cannot be zero");
        require(!_exists(_tokenId), "Already exists");

        _owners[_tokenId] = _to;
        _balances[_to]++;
    }

    function burn(uint _tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "Not an owner");

        address owner = ownerOf(_tokenId);

        delete _tokenApprovals[_tokenId];
        _balances[owner]--;
        delete _owners[_tokenId];
    }

    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function _safeTransfer(address _from, address _to, uint _tokenId) internal {
        _transfer(_from, _to, _tokenId);

        require(
            _checkOnERC721Received(_from, _to, _tokenId),
            "Non ERC721 receiver"
        );
    }

    function _checkOnERC721Received(
        address _from,
        address _to,
        uint _tokenId
    ) private returns (bool) {
        if (_to.code.length > 0) {
            // if receiver is smart contract
            try
                IERC721Receiver(_to).onERC721Received(
                    _from,
                    _to,
                    _tokenId,
                    bytes("")
                )
            returns (bytes4 ret) {
                ret == IERC721Receiver.onERC721Received.selector; // ready to receive NFT
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // receiver not implementin IERC721Receiver and dont have onERC721Received function
                    revert("Non ERC721 receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            // if receiver is not smart contract
            return true;
        }
    }

    function _baseURI() internal pure virtual returns (string memory) {
        return "";
    }

    function tokenURI(
        uint _tokenId
    ) public view virtual _requireMinted(_tokenId) returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _tokenId.toString()))
                : "";
    }

    function supportsInterface(
        bytes4 interfaceId
    ) external pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _transfer(address _from, address _to, uint _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "Not an owner");
        require(_to != address(0), "_to cannot be zero");

        _beforeTokenTransfer(_from, _to, _tokenId);

        _balances[_from]--;
        _balances[_to]++;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId);
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint _tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address _from,
        address _to,
        uint _tokenId
    ) internal virtual {}

    function _isApprovedOrOwner(
        address _spender,
        uint _tokenId
    ) internal view returns (bool) {
        address owner = ownerOf(_tokenId);

        require(
            owner == _spender ||
                isApprovedForAll(owner, _spender) ||
                getApproved(_tokenId) == _spender,
            "Not an owner or approved"
        );
    }

    function _exists(uint _tokenId) internal view returns (bool) {
        return _owners[_tokenId] != address(0);
    }
}
