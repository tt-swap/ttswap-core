// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largely inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library L_OrderStatus {
    using L_OrderStatus for mapping(uint256 => uint256);

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(
        mapping(uint256 => uint256) storage _orderStatus,
        uint256 index
    ) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return _orderStatus[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        mapping(uint256 => uint256) storage _orderStatus,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(_orderStatus, index);
        } else {
            unset(_orderStatus, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(
        mapping(uint256 => uint256) storage _orderStatus,
        uint256 index
    ) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        _orderStatus[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(
        mapping(uint256 => uint256) storage _orderStatus,
        uint256 index
    ) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        _orderStatus[bucket] &= ~mask;
    }

    function getValidOrderId(
        mapping(uint256 => uint256) storage _orderStatus,
        uint256 index,
        uint256 _maxslot
    ) internal returns (uint256 orderid) {
        bool result = true;
        uint256 bucket = index >> 8;
        uint256 batchorder;
        while (result) {
            batchorder = _orderStatus[bucket];
            index = index & 0xff;
            while (index < 255 && result) {
                index = index + 1;
                result = batchorder & (1 << index) != 0;
            }
            if (index == 256) {
                bucket = bucket == _maxslot ? 0 : bucket + 1;
                index = 0;
            }
        }
        orderid = (bucket << 8) + index;
        _orderStatus.set(index);
    }
}
