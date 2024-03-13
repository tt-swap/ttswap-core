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
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract disinvestValueGoodNoFee is BaseSetup {
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

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
        uint256 _goodconfig = 2 ** 255;
        market.initMetaGood(
            goodkey,
            toBalanceUINT256(20000, 20000),
            _goodconfig
        );
        metagood = S_GoodKey({
            erc20address: T_Currency.wrap(address(btc)),
            owner: marketcreator
        }).toId();
        //market.updatetoValueGood(metagood);
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
            refer: address(2),
            recipent: users[6]
        });
        market.investValueGood(metagood, 20000, _ralate);
        p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
        vm.stopPrank();
    }

    function testdisinvestvaluegood(uint256 aquanity) public {
        vm.startPrank(users[2]);
        vm.assume(aquanity > 1 && aquanity < 1000);
        uint128 quanity = uint128(aquanity);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3),
            recipent: users[6]
        });
        snapStart("disinvest Value good No Fee first");
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
            40000 - quanity,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            40000 - quanity,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            40000 - quanity,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            40000 - quanity,
            "investState's quantity is error"
        );
        assertEq(
            aa.feeQunitityState.amount1(),
            0,
            "feeQunitityState's feeamount is error"
        );
        assertEq(
            aa.feeQunitityState.amount0(),
            0,
            "feeQunitityState's contruct fee is error"
        );
        snapStart("disinvest Value good No Fee second");
        result = market.disinvestValueGood(metagood, quanity, _ralate);
        snapEnd();

        vm.stopPrank();
    }

    function testdisinvestvalueproof(uint256 aquanity) public {
        vm.startPrank(users[2]);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({
            gater: address(1),
            refer: address(3),
            recipent: users[6]
        });
        vm.assume(aquanity > 1 && aquanity < 1000);
        uint128 quanity = uint128(aquanity);
        T_ProofId p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();

        snapStart("disinvest Value proof No Fee first");
        T_BalanceUINT256 result = market.disinvestValueProof(
            p_,
            quanity,
            _ralate
        );
        snapEnd();
        S_GoodState memory aa = market.getGoodState(metagood);
        assertEq(result.amount0(), 0, "disinvest proof 's value is error");
        assertEq(result.amount1(), 0, "disinvest proof 's quantity is error");
        assertEq(
            aa.currentState.amount0(),
            40000 - quanity,
            "currentState's value is error"
        );
        assertEq(
            aa.currentState.amount1(),
            40000 - quanity,
            "currentState's quantity is error"
        );

        assertEq(
            aa.investState.amount0(),
            40000 - quanity,
            "investState's value is error"
        );
        assertEq(
            aa.investState.amount1(),
            40000 - quanity,
            "investState's quantity is error"
        );
        assertEq(
            aa.feeQunitityState.amount1(),
            0,
            "feeQunitityState's feeamount is error"
        );
        assertEq(
            aa.feeQunitityState.amount0(),
            0,
            "feeQunitityState's contruct fee is error"
        );
        snapStart("disinvest Value proof No Fee second");
        result = market.disinvestValueProof(p_, 10, _ralate);
        snapEnd();
        vm.stopPrank();
    }
}
