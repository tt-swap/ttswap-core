// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

contract MyToken is ERC20 {
    address public owner;

    constructor(
        string memory name,
        string memory symbol,
        uint8 _decimals
    ) ERC20(name, symbol, _decimals) {
        owner = msg.sender;
        _mint(msg.sender, 100000000 * 10 ** decimals);
    }

    function mint(address recipent, uint amount) external {
        require(amount <= 100000000);
        _mint(recipent, amount * 10 ** decimals);
    }
}
