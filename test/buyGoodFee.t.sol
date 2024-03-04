pragma solidity ^0.8.13;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey} from "../Contracts/types/S_GoodKey.sol";
import {T_GoodId, L_GoodIdLibrary} from "../Contracts/types/T_GoodId.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/types/T_BalanceUINT256.sol";
import {S_ProofKey, S_ProofState} from "../Contracts/types/S_ProofKey.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../Contracts/libraries/L_MarketConfig.sol";
import {L_Ralate} from "../Contracts/libraries/L_Ralate.sol";
import {GoodUtil} from "./util/GoodUtil.sol";
import {L_Ralate} from "../Contracts/libraries/L_Ralate.sol";

contract buyGoodFee is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    T_GoodId metagood;
    T_GoodId normalgoodusdt;
    T_GoodId normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        normalgoodusdt = initNormalGood(address(usdt));
    }

    function initmetagood() public {
        S_GoodKey memory goodkey = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        });
        vm.startPrank(marketcreator);
        deal(address(btc), marketcreator, 1000000000, false);
        btc.approve(address(market), 20000000);

        uint256 _goodConfig = 2 ** 255 +
            8 *
            2 ** 245 +
            8 *
            2 ** 235 +
            8 *
            2 ** 225 +
            8 *
            2 ** 215;
        market.initMetaGood(
            goodkey,
            toBalanceUINT256(20000000, 20000000),
            _goodConfig
        );
        uint256 _marketConfig = (50 << 250) +
            (5 << 244) +
            (10 << 238) +
            (15 << 232) +
            (20 << 226) +
            (20 << 220);

        market.setMarketConfig(_marketConfig);
        metagood = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        }).toId();
        //market.updatetoValueGood(metagood);
        vm.stopPrank();
    }

    function initNormalGood(
        address token
    ) public returns (T_GoodId normalgood) {
        vm.startPrank(users[3]);
        deal(address(btc), users[3], 100000000, false);
        btc.approve(address(market), 20000000);
        deal(token, users[3], 100000000, false);
        MyToken(token).approve(address(market), 20000000);
        uint256 _goodConfig = 0 *
            2 ** 255 +
            8 *
            2 ** 245 +
            8 *
            2 ** 235 +
            8 *
            2 ** 225 +
            8 *
            2 ** 215;
        normalgood = S_GoodKey({
            erc20address: T_Currency.wrap(address(token)),
            owner: users[3]
        }).toId();
        market.initNormalGood(
            metagood,
            toBalanceUINT256(20000000, 20000000),
            T_Currency.wrap(token),
            _goodConfig
        );
        vm.stopPrank();
    }

    function testBuyGood() public {
        vm.startPrank(users[6]);
        deal(address(usdt), users[6], 1000000000, false);
        usdt.approve(address(market), 100000000);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3)
        });
        S_GoodState memory s1 = market.getGoodState(metagood);
        GoodUtil.showGood(s1);
        S_GoodState memory s2 = market.getGoodState(normalgoodusdt);
        GoodUtil.showGood(s2);

            uint128 goodid2Quanitity_;
            uint128 goodid2FeeQuanitity_;
            snapStart("buygood with fee without chips first");
        (
         
             goodid2Quanitity_,
             goodid2FeeQuanitity_
        ) = market.buyGood(
                normalgoodusdt,
                metagood,
                1000000,
                T_BalanceUINT256.unwrap(toBalanceUINT256(2, 1)),
                _ralate
            );
        snapEnd();
        console2.log(
            goodid2Quanitity_,
            goodid2FeeQuanitity_
        );
        s1 = market.getGoodState(metagood);
        s2 = market.getGoodState(normalgoodusdt);
        GoodUtil.showGood(s1);
        GoodUtil.showGood(s2);

        snapStart("buygood with fee without chips second");
        (
         
             goodid2Quanitity_,
             goodid2FeeQuanitity_
        ) = market.buyGood(
                normalgoodusdt,
                metagood,
                1000000,
                T_BalanceUINT256.unwrap(toBalanceUINT256(2, 1)),
                _ralate
            );
        snapEnd();
    }
}
