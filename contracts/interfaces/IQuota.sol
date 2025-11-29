// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import {IERC1155Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

interface IQuota is IERC1155MetadataURI, IERC1155Errors {
    /**
     * @notice Sets a new URI for the token.
     * @dev This function can only be called by an account with the TOKEN_MANAGER_ROLE.
     * @param newUri The new URI to be set for the token.
     */
    function setURI(string memory newUri) external;

    /**
     * @notice Burn and delete a quota.
     * @dev This function can only be called by an account with the TOKEN_MANAGER_ROLE.
     * @param id The ID of the quota to be burned.
     * @param account Token owner address
     * @param amount Quantity to be burned
     */
    function burn(address account, uint256 id, uint256 amount) external;
}
