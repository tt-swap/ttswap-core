// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/testtoken/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup2.t.sol";
import {S_GoodKey, S_Ralate, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

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
    using L_BalanceUINT256Library for T_BalanceUINT256;

    uint256 metagood;
    uint256 normalgoodbtc;
    uint256 normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        goodPrice(metagood);
        normalgoodbtc = initNormalGood(address(btc), 100, 64000);
        showconfig(market.getGoodState(metagood).goodConfig);
        goodPrice(metagood);
        normalgoodeth = initNormalGood(address(eth), 100, 3100);

        goodPrice(metagood);
        goodPrice(normalgoodbtc);
        goodPrice(normalgoodeth);
    }

    function initmetagood() public {
        vm.startPrank(marketcreator);
        deal(address(usdt), marketcreator, 100000 * 10 ** 6, false);
        usdt.approve(address(market), 30000 * 10 ** 6);
        uint256 _goodConfig = 2 ** 255 +
            8 *
            2 ** 245 +
            8 *
            2 ** 238 +
            8 *
            2 ** 231 +
            8 *
            2 ** 224;
        (metagood, ) = market.initMetaGood(
            address(usdt),
            toBalanceUINT256(20000 * 10 ** 6, 20000 * 10 ** 6),
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

    function initNormalGood(
        address token,
        uint128 amount,
        uint128 price
    ) public returns (uint256 normalgood) {
        vm.startPrank(users[3]);
        uint128 decimals = uint128(10 ** MyToken(token).decimals());
        deal(token, users[3], amount * decimals, false);
        MyToken(token).approve(address(market), amount * decimals);

        deal(
            address(usdt),
            users[3],
            amount * price * 10 ** usdt.decimals(),
            false
        );
        console2.log("usdt approve", amount * price * 10 ** usdt.decimals());
        usdt.approve(address(market), amount * price * 10 ** usdt.decimals());
        console2.log(
            "users[3] approve market",
            usdt.allowance(users[3], address(market))
        );

        uint256 _goodConfig = 8 *
            2 ** 245 +
            8 *
            2 ** 238 +
            8 *
            2 ** 231 +
            8 *
            2 ** 224;

        (normalgood, ) = market.initNormalGood(
            metagood,
            toBalanceUINT256(
                amount * decimals,
                uint128(amount * price * 10 ** usdt.decimals())
            ),
            token,
            _goodConfig,
            msg.sender
        );
        vm.stopPrank();
    }

    function goodPrice(uint256 _good1) public {
        console2.log(_good1, "************************");
        console2.log(
            "price good1's value",
            market.getGoodState(_good1).currentState.amount0()
        );
        console2.log(
            "price good1's quantity",
            market.getGoodState(_good1).currentState.amount1()
        );

        console2.log(
            "price good1's invest value",
            market.getGoodState(_good1).investState.amount0()
        );
        console2.log(
            "price good1's invest quantity",
            market.getGoodState(_good1).investState.amount1()
        );

        console2.log(
            "price good1's fee",
            market.getGoodState(_good1).feeQunitityState.amount0()
        );

        console2.log(
            "price good1's contrunct fee",
            market.getGoodState(_good1).feeQunitityState.amount1()
        );
    }

    function showconfig(uint256 _goodConfig) public pure {
        console2.log("good goodConfig:isvaluegood:", _goodConfig.isvaluegood());
        console2.log(
            "good goodConfig:getInvestFee:",
            uint256(_goodConfig.getInvestFee())
        );
        console2.log(
            "good goodConfig:getDisinvestFee:",
            uint256(_goodConfig.getDisinvestFee())
        );
        console2.log(
            "good goodConfig:getBuyFee:",
            uint256(_goodConfig.getBuyFee())
        );
        console2.log(
            "good goodConfig:getSellFee:",
            uint256(_goodConfig.getSellFee())
        );
        console2.log(
            "good goodConfig:getSwapChips:",
            uint256(_goodConfig.getSwapChips())
        );
    }
    function testbuy() public {}
}
