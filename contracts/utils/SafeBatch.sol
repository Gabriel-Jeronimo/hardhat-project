// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

abstract contract SafeBatch {
    uint8 public maxInteractions = 50;

    /**
     * @dev Notice the maximum number of interactions is updated.
     * @param newMaxInteractions The new value for the maximum number of interactions allowed in a batch.
     */
    event MaxInteractionsUpdated(uint8 newMaxInteractions);

    /// @notice Thrown when the size of an array exceeds the maximum allowed interactions in a batch.
    /// @param arrayLength The length of the array.
    /// @param maxInteractions The maximum number of interactions allowed in a loop.
    error CallSurpassMaximumInteractions(
        uint256 arrayLength,
        uint256 maxInteractions
    );

    /// @notice Thrown when attempting to set maximum interactions to zero.
    error MaxInteractionsMustBeGreaterThanZero();

    /// @notice Thrown when attempting to set maximum interactions to the same value.
    /// @param currentMaxInteractions The current maximum interactions value.
    error MaxInteractionsMustBeDifferent(uint8 currentMaxInteractions);

    /**
     * @notice Restricts the number of batch interactions to prevent potential DoS attacks.
     * @dev This modifier checks if the number of interactions in a batch operation exceeds the maximum allowed.
     * @param number The number of interactions to be performed in the batch operation.
     * @custom:throws CallSurpassMaximumInteractions If the number of interactions exceeds the maximum allowed.
     */
    modifier allowedInteraction(uint256 number) {
        if (number > maxInteractions) {
            revert CallSurpassMaximumInteractions(number, maxInteractions);
        }
        _;
    }

    /**
     * @notice Updates the maximum number of interactions allowed per batch
     * @dev This function allows the modification of the maximum number of interactions
     *      permitted in a batch operation. It enforces that the new value must be
     *      greater than zero and different from the current value.
     * @param newMaxInteractions The new maximum number of interactions to be set
     * @custom:events Emits MaxInteractionsUpdated when the maximum is successfully updated
     * @custom:errors Reverts with MaxInteractionsMustBeGreaterThanZero if the new value is zero
     * @custom:errors Reverts with MaxInteractionsMustBeDifferent if the new value equals the current value
     */
    function setMaxInteractions(uint8 newMaxInteractions) public virtual {
        if (newMaxInteractions == 0) {
            revert MaxInteractionsMustBeGreaterThanZero();
        }

        if (newMaxInteractions == maxInteractions) {
            revert MaxInteractionsMustBeDifferent(maxInteractions);
        }

        maxInteractions = newMaxInteractions;
        emit MaxInteractionsUpdated(newMaxInteractions);
    }
}
