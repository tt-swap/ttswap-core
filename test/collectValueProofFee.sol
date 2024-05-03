// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_Ralate, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract collectValueProofFee is Test, BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        normalgoodusdt = initNormalGood(address(usdt));
        normalgoodeth = initNormalGood(address(eth));
    }

    function initmetagood() public {
        vm.startPrank(marketcreator);
        deal(address(btc), marketcreator, 100000, false);
        btc.approve(address(market), 30000);
        uint256 _goodConfig = 2 ** 255 + 8 * 2 ** 245 + 8 * 2 ** 238;
        (metagood, ) = market.initMetaGood(
            address(btc),
            toBalanceUINT256(20000, 20000),
            _goodConfig
        );

        //market.updatetoValueGood(metagood);
        uint256 _marketConfig = (50 << 250) +
            (5 << 244) +
            (10 << 238) +
            (10 << 232) +
            (25 << 226) +
            (20 << 220);
        console2.log(_marketConfig);

        market.setMarketConfig(_marketConfig);
        vm.stopPrank();
        console2.log(
            market.getGoodsFee(metagood, marketcreator),
            "marketcreater2"
        );
    }

    function initNormalGood(address token) public returns (uint256 normalgood) {
        vm.startPrank(users[3]);
        deal(address(btc), users[3], 100000, false);
        btc.approve(address(market), 20000);
        deal(token, users[3], 100000, false);
        MyToken(token).approve(address(market), 20000);

        uint256 _goodConfig = 8 * 2 ** 245 + 8 * 2 ** 238;

        (normalgood, ) = market.initNormalGood(
            metagood,
            toBalanceUINT256(20000, 20000),
            token,
            _goodConfig,
            msg.sender
        );
        vm.stopPrank();
    }
}
