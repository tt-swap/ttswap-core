// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @notice
library L_TTSTokenConfigLibrary {
    //商品配置
    function ismain(uint256 config) internal pure returns (bool a) {
        uint256 b;
        assembly {
            b := shr(255, config)
        }
        return b == 1 ? true : false;
    }
}
