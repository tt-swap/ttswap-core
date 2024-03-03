pragma solidity ^0.8.13;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey} from "../Contracts/types/S_GoodKey.sol";
import {S_ProofKey} from "../Contracts/types/S_ProofKey.sol";
import {T_GoodId, L_GoodIdLibrary} from "../Contracts/types/T_GoodId.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/types/T_BalanceUINT256.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";
import {T_ProofId, L_ProofIdLibrary} from "../Contracts/types/T_ProofId.sol";

contract testinvestGood is BaseSetup {
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    T_GoodId metagood;

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
        GoodUtil.showGood(market.getGoodState(metagood));
        T_ProofId normalproof = S_ProofKey(msg.sender, metagood, T_GoodId.wrap(0)).toId();
        ProofUtil.showproof(market.getProofState(normalproof));
        vm.stopPrank();
    }

    function testinitNormalGood() public {
        vm.startPrank(users[1]);
        deal(address(btc), users[1], 100000, false);
        btc.approve(address(market), 10000);
        console2.log(btc.balanceOf(users[1]));
        deal(address(usdt), users[1], 100000, false);
        usdt.approve(address(market), 10000);
        console2.log(usdt.balanceOf(users[1]));
        snapStart("init normalgood");
        market.initNormalGood(metagood, toBalanceUINT256(1000, 1000), T_Currency.wrap(address(usdt)), 1);
        snapEnd();
        vm.stopPrank();
    }
}
