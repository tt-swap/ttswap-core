// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface I_Referer {
    /// @notice user add referer~用户添加推荐人
    /// @param _referer   address or referer~推荐人地址
    function addreferer(address _referer) external returns (bool is_success_);
}
