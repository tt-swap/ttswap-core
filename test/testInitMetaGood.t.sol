pragma solidity ^0.8.13;

import {Test, DSTest, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey} from "../Contracts/types/S_GoodKey.sol";
import {S_ProofKey} from "../Contracts/types/S_ProofKey.sol";
import {T_GoodId, L_GoodIdLibrary} from "../Contracts/types/T_GoodId.sol";
import {T_ProofId, L_ProofIdLibrary} from "../Contracts/types/T_ProofId.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract testInitMetaGood is BaseSetup {
    using L_ProofIdLibrary for S_ProofKey;
    using L_GoodIdLibrary for S_GoodKey;

    T_GoodId metagood;

    function setUp() public override {
        BaseSetup.setUp();
    }

    function testinitMetaGood() public {
        S_GoodKey memory goodkey = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator});
        vm.startPrank(marketcreator);
        uint256 goodconfig = 2 ** 255;
        deal(address(btc), marketcreator, 100000, false);
        console2.log(btc.balanceOf(marketcreator));
        btc.approve(address(market), 30000);
        snapStart("init metagood");
        market.initMetaGood(goodkey, toBalanceUINT256(20000, 20000), goodconfig);
        snapEnd();
        metagood = S_GoodKey({erc20address: T_Currency.wrap(address(btc)), owner: marketcreator}).toId();
        S_GoodState memory good_ = market.getGoodState(metagood);
        GoodUtil.showGood(good_);
        T_ProofId normalproof = S_ProofKey(marketcreator, metagood, T_GoodId.wrap(0)).toId();
        ProofUtil.showproof(market.getProofState(normalproof));
        vm.stopPrank();
    }
}
