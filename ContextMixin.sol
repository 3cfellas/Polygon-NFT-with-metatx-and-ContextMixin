// SPDX-License-Identifier: MIT
// Upgraded ContextMixin.sol to work with solidity 0.8.19

pragma solidity 0.8.19;

abstract contract ContextMixin {
    function msgSender()
        internal
        view
        virtual
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender); //adding msg.sender here to comply with current solidity version

        }
        return sender;
    }
}
