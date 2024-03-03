pragma solidity ^0.8.13;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_GoodState} from "../Contracts/types/S_GoodKey.sol";
import {T_GoodId, L_GoodIdLibrary} from "../Contracts/types/T_GoodId.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/types/T_BalanceUINT256.sol";

import {T_ProofId, L_ProofIdLibrary} from "../Contracts/types/T_ProofId.sol";
import {S_ProofKey, S_ProofState} from "../Contracts/types/S_ProofKey.sol";
import {L_Ralate} from "../Contracts/libraries/L_Ralate.sol";
import {L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract disinvestValueGoodFee is BaseSetup {
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;
    using L_GoodConfigLibrary for uint256;

    T_GoodId metagood;
    T_GoodId normalgoodusdt;
    T_GoodId normalgoodeth;
    T_ProofId valueProof;
    T_ProofId normalProofusdt;
    T_ProofId normalProofeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        valueProof = investValueGood();
    }

    function initmetagood() public {
        S_GoodKey memory goodkey = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        });
        vm.startPrank(marketcreator);
        deal(address(btc), marketcreator, 100000, false);
        btc.approve(address(market), 30000);
        uint256 _goodConfig = 1 * 2 ** 255 + 8 * 2 ** 245 + 8 * 2 ** 235;
        market.initMetaGood(
            goodkey,
            toBalanceUINT256(20000, 20000),
            _goodConfig
        );
        metagood = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        }).toId();
        //market.updatetoValueGood(metagood);

        uint256 _marketConfig = (50 << 250) +
            (5 << 244) +
            (10 << 238) +
            (15 << 232) +
            (20 << 226) +
            (20 << 220);
        market.setMarketConfig(_marketConfig);
        console2.log(_goodConfig.isvaluegood(), "1");
        console2.log(_goodConfig.getInvestFee(), "2");
        console2.log(_goodConfig.getDisinvestFee(), "3");
        snapStart("updateGoodConfig");
        market.updateGoodConfig(metagood, _goodConfig);
        snapEnd();
        vm.stopPrank();
    }

    function investValueGood() public returns (T_ProofId p_) {
        vm.startPrank(users[2]);
        deal(
            T_Currency.unwrap(market.getGoodState(metagood).erc20address),
            users[2],
            200000,
            false
        );
        MyToken(T_Currency.unwrap(market.getGoodState(metagood).erc20address))
            .approve(address(market), 100000);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(2)
        });
        snapStart("investValuegoodwithfee first");
        market.investValueGood(metagood, 20000, _ralate);
        snapEnd();
        p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
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
            aa.feeQunitityState.amount0(),
            8,
            "feeQunitityState's feeamount is error"
        );
        assertEq(
            aa.feeQunitityState.amount1(),
            0,
            "feeQunitityState's contruct fee is error"
        );

      
        vm.stopPrank();
    }

    function testdisinvestvaluegood(uint256 aquanity) public {
        vm.startPrank(users[2]);
        vm.assume(aquanity > 1 && aquanity < 1000);
        uint128 quanity = uint128(aquanity);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3)
        });
        snapStart("disinvestValueGoodWithFee first");
        T_BalanceUINT256 result = market.disinvestValueGood(
            metagood,
            quanity,
            _ralate
        );
        snapEnd();
        S_GoodState memory aa = market.getGoodState(metagood);
        assertEq(result.amount0(), 0, "disinvest proof 's value is error");
        assertEq(result.amount1(), 0, "disinvest proof 's quantity is error");
        assertEq(
            aa.currentState.amount0(),
            39984 - quanity,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            39984 - quanity,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            39984 - quanity,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            39984 - quanity,
            "investState's quantity is error"
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
        console2.log(
            uint256(aa.feeQunitityState.amount0()),
            uint256(aa.feeQunitityState.amount1())
        );
        snapStart("disinvestValueGoodWithFee second");
         result = market.disinvestValueGood(
            metagood,
            10,
            _ralate
        );
        snapEnd();
        vm.stopPrank();
    }

    function testdisinvestvalueproof(uint256 aquanity) public {
        vm.startPrank(users[2]);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3)
        });
        vm.assume(aquanity > 1 && aquanity < 1000);
        uint128 quanity = uint128(aquanity);
        T_ProofId p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
        snapStart("disinvestValueProofwithfee first");
        T_BalanceUINT256 result = market.disinvestValueProof(
            p_,
            quanity,
            _ralate
        );
        snapEnd();
        S_GoodState memory aa = market.getGoodState(metagood);

        console2.log(quanity);
        assertEq(result.amount0(), 0, "disinvest proof 's value is error");
        assertEq(result.amount1(), 0, "disinvest proof 's quantity is error");
        assertEq(
            aa.currentState.amount0(),
            39984 - quanity,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            39984 - quanity,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            39984 - quanity,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            39984 - quanity,
            "investState's quantity is error"
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
        snapStart("disinvestValueProofwithfee second");
         result = market.disinvestValueProof(
            p_,
            10,
            _ralate
        );
        snapEnd();
        vm.stopPrank();
    }

    function testdisinvestvalueproof1() public {
        vm.startPrank(users[2]);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3)
        });

        uint128 quanity = 10000;
        T_ProofId p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
        T_BalanceUINT256 result = market.disinvestValueProof(
            p_,
            quanity,
            _ralate
        );
        S_GoodState memory aa = market.getGoodState(metagood);

        console2.log(quanity);
        assertEq(result.amount0(), 2, "disinvest proof 's value is error");
        assertEq(result.amount1(), 8, "disinvest proof 's quantity is error");
        assertEq(
            aa.currentState.amount0(),
            39984 - quanity,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            39984 - quanity,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            39984 - quanity,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            39984 - quanity,
            "investState's quantity is error"
        );
        assertEq(
            aa.feeQunitityState.amount1(),
            0,
            "feeQunitityState's feeamount is error"
        );
        assertEq(
            aa.feeQunitityState.amount0(),
            10,
            "feeQunitityState's contruct fee is error"
        );
        vm.stopPrank();
    }

    function testdisinvestvalueproof2() public {
        vm.startPrank(users[2]);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3)
        });

        uint128 quanity = 500;
        T_ProofId p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
        T_BalanceUINT256 result = market.disinvestValueProof(
            p_,
            quanity,
            _ralate
        );

        result = market.disinvestValueProof(p_, quanity, _ralate);

        vm.stopPrank();
    }
}
