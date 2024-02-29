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

contract investValueGoodFee is BaseSetup {
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
    }

    function initmetagood() public {
        S_GoodKey memory goodkey = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        });
        vm.startPrank(marketcreator);
        deal(address(btc), marketcreator, 100000, false);
        btc.approve(address(market), 30000);
        uint256 _goodconfig = 2 ** 255;
        uint256 _marketConfig = (50 << 250) +
            (5 << 244) +
            (10 << 238) +
            (15 << 232) +
            (20 << 226) +
            (20 << 220);
        market.initMetaGood(
            goodkey,
            toBalanceUINT256(20000, 20000),
            _goodconfig
        );
        market.setMarketConfig(_marketConfig);
        metagood = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        }).toId();
        // market.updatetoValueGood(metagood);
        uint256 _goodConfig = 1 * 2 ** 255 + 8 * 2 ** 245 + 8 * 2 ** 235;
        console2.log(_marketConfig.checkAllocate());
        console2.log(_marketConfig.getLiquidFee(), "liqiuid");
        console2.log(_marketConfig.getSellerFee(), "seller");
        console2.log(_marketConfig.getGaterFee(), "gater");
        console2.log(_marketConfig.getReferFee(), "refer");
        console2.log(_marketConfig.getCustomerFee(), "customer");
        console2.log(_marketConfig.getPlatFee(), "plat");
        console2.log(_goodConfig.isvaluegood(), "1");
        console2.log(_goodConfig.getInvestFee(), "2");
        console2.log(_goodConfig.getDisinvestFee(), "3");
        market.updateGoodConfig(metagood, _goodConfig);
        vm.stopPrank();
    }

    function testinvestValueGood(uint256) public {
        vm.startPrank(users[4]);
        deal(
            T_Currency.unwrap(market.getGoodState(metagood).erc20address),
            users[4],
            100000,
            false
        );
        MyToken(T_Currency.unwrap(market.getGoodState(metagood).erc20address))
            .approve(address(market), 100000);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(2)
        });
        market.investValueGood(metagood, 20000, _ralate);
        T_ProofId p_ = S_ProofKey(users[4], metagood, T_GoodId.wrap(0)).toId();
        S_GoodState memory aa = market.getGoodState(metagood);
        S_ProofState memory _s = market.getProofState(p_);
        assertEq(_s.extends.amount0(), 19984, "proof's value is error");
        assertEq(_s.invest.amount0(), 0, "proof's contruct quantity is error");
        assertEq(_s.invest.amount1(), 19984, "proof's quantity is error");

        assertEq(
            aa.currentState.amount0(),
            39984,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            39984,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            39984,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            39984,
            "investState's quantity is error"
        );
        console2.log(
            uint256(aa.feeQunitityState.amount0()),
            uint256(aa.feeQunitityState.amount1())
        );
        assertEq(
            aa.feeQunitityState.amount1(),
            0,
            "feeQunitityState's feeamount is error"
        );
        assertEq(
            aa.feeQunitityState.amount0(),
            8,
            "feeQunitityState's contruct fee is error"
        );

        assertEq(
            uint256(market.getGoodsFee(metagood, users[4])),
            3,
            "customer fee"
        );
        assertEq(
            uint256(market.getGoodsFee(metagood, marketcreator)),
            0,
            "seller fee"
        );
        assertEq(market.getGoodsFee(metagood, address(1)), 1, "gater fee");
        assertEq(market.getGoodsFee(metagood, address(2)), 2, "refer fee");

        market.investValueGood(metagood, 20000, _ralate);
        vm.stopPrank();
    }
}
