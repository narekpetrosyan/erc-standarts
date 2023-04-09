// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external returns (string memory);

    function symbol() external returns (string memory);

    function tokenUri(uint tokenId) external returns (string memory);
}
