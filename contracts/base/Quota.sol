// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IQuota} from "../interfaces/IQuota.sol";
import {QuotaState} from "./QuotaState.sol";
import {IQuotaErrors} from "../interfaces/IQuotaErrors.sol";

abstract contract Quota is IQuota, ERC1155Supply, QuotaState, IQuotaErrors {
    constructor(string memory metadataUri) ERC1155(metadataUri) {}

    modifier onlyIfQuotaExists(uint256 quotaId) {
        if (!exists(quotaId)) {
            revert QuotaIdDoesntExists(quotaId);
        }
        _;
    }

    /// @inheritdoc IQuota
    function setURI(
        string memory newUri
    ) public {
        _setURI(newUri);
    }

    /// @inheritdoc IQuota
    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public override {
        delete quotaData[id];
        _burn(account, id, amount);
    }

    /**
     * @dev Internal function to update the state of the contract when tokens are transferred.
     * This function overrides the _update function from both ERC1155Supply and ERC1155Pausable.
     * It calls the super implementation to ensure the proper handling of token transfers.
     *
     * @param from The address of the sender.
     * @param to The address of the recipient.
     * @param ids An array of token IDs being transferred.
     * @param values An array of amounts of tokens being transferred.
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * This function checks if the contract implements the interface defined by
     * `interfaceId`. It uses the `supportsInterface` function from the parent
     * `ERC1155` contract to perform the check.
     *
     * @param interfaceId The interface identifier, as specified in ERC-165.
     * @return bool True if the contract implements the requested interface, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, IERC165) returns (bool) {
        return
            interfaceId == type(IQuota).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
