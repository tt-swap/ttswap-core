// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from "./IERC20.sol";

interface IRocketTokenRETH {
    function getEthValue(uint256 _rethAmount) external view returns (uint256);
    function getRethValue(uint256 _ethAmount) external view returns (uint256);
    function mint(uint256 _ethAmount, address _to) external;
    function burn(uint256 _rethAmount) external;
}
