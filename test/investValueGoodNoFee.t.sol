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

contract investValueGoodNoFee is BaseSetup {
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
        S_GoodKey memory goodkey = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator});
        vm.startPrank(marketcreator);
        deal(address(btc), marketcreator, 100000, false);
        btc.approve(address(market), 30000);
        uint256 _goodconfig = 2 ** 255;
        market.initMetaGood(goodkey, toBalanceUINT256(20000, 20000), _goodconfig);
        metagood = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator}).toId();
        // market.updatetoValueGood(metagood);
        vm.stopPrank();
    }

    function testinvestValueGood(uint256) public {
        vm.startPrank(users[2]);
        deal(T_Currency.unwrap(market.getGoodState(metagood).erc20address), users[2], 100000, false);
        MyToken(T_Currency.unwrap(market.getGoodState(metagood).erc20address)).approve(address(market), 200000);
        L_Ralate.S_Ralate memory _ralate = L_Ralate.S_Ralate({gater: address(1), refer: address(2)});
        snapStart("invest value good no fee first");
        market.investValueGood(metagood, 20000, _ralate);
        snapEnd();
        T_ProofId p_ = S_ProofKey(users[2], metagood, T_GoodId.wrap(0)).toId();
        S_GoodState memory aa = market.getGoodState(metagood);
        S_ProofState memory _s = market.getProofState(p_);
        assertEq(_s.extends.amount0(), 20000, "proof's value is error");
        assertEq(_s.invest.amount0(), 0, "proof's contruct quantity is error");
        assertEq(_s.invest.amount1(), 20000, "proof's quantity is error");

        assertEq(aa.currentState.amount0(), 40000, "currentState's value is error");
        assertEq(aa.currentState.amount1(), 40000, "currentState's quantity is error");

        assertEq(aa.investState.amount0(), 40000, "investState's value is error");
        assertEq(aa.investState.amount1(), 40000, "investState's quantity is error");
        console2.log(uint256(aa.feeQunitityState.amount0()), uint256(aa.feeQunitityState.amount1()));
        assertEq(aa.feeQunitityState.amount1(), 0, "feeQunitityState's feeamount is error");
        assertEq(aa.feeQunitityState.amount0(), 0, "feeQunitityState's contruct fee is error");

        assertEq(uint256(market.getGoodsFee(metagood, users[2])), 0, "customer fee");
        assertEq(uint256(market.getGoodsFee(metagood, marketcreator)), 0, "seller fee");
        assertEq(market.getGoodsFee(metagood, address(1)), 0, "gater fee");
        assertEq(market.getGoodsFee(metagood, address(2)), 0, "refer fee");
  snapStart("invest value good no fee second");
        market.investValueGood(metagood, 20000, _ralate);
        snapEnd();
        vm.stopPrank();
    }
}
