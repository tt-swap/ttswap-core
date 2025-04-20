// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/test/MyToken.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toUint128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";

import {rocketpoolmock} from "../src/test/rocketpoolmock.sol";
import {TTSwap_Stake_Mock} from "../src/test/TTSwap_Stake_Mock.sol";

import {WETH} from "solmate/src/tokens/WETH.sol";

contract StakeETHSETH is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;

    using L_ProofIdLibrary for S_ProofKey;

    address metagood;
    address normalgoodusdt;
    address normalgoodeth;
    rocketpoolmock reth1 =
        rocketpoolmock(payable(0x7322c24752f79c05FFD1E2a6FCB97020C1C264F1)); //hoodi address
    address payable reth = payable(0x7322c24752f79c05FFD1E2a6FCB97020C1C264F1); //hoodi address
    MyToken weth1;
    address payable weth = payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF);
    address payable sweth = payable(address(3));
    address payable seth = payable(address(2));
    TTSwap_Stake_Mock ttswapstake;

    function setUp() public override {
        BaseSetup.setUp();
        ttswapstake = new TTSwap_Stake_Mock(
            marketcreator,
            market,
            IERC20(address(tts_token))
        );
        initRethToken();
        weth1 = new MyToken("WETH", "WETH", 18);
        vm.etch(weth, address(weth1).code);
        initmetagood();

        // investOwnERC20ValueGood();
    }

    function initRethToken() public {
        reth1 = new rocketpoolmock("Reth", "Reth", 18);
        vm.etch(reth, address(reth1).code);

        // vm.etch(reth, rocketpoolmock("Reth", "Reth", 18));
    }

    function initmetagood() public {
        deal(marketcreator, 1000 * 10 ** 18);
        vm.startPrank(marketcreator);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        assertEq(address(market).balance, 0, "init1 metagood market eth error");
        market.initMetaGood{value: 100 * 10 ** 18}(
            address(1),
            toTTSwapUINT256(157000 * 10 ** 6, 100 * 10 ** 18),
            _goodconfig,
            defaultdata
        );

        assertEq(
            address(market).balance,
            100 * 10 ** 18,
            "init2 metagood market eth error"
        );

        _goodconfig =
            (2 ** 255) +
            1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initMetaGood{value: 100 * 10 ** 18}(
            seth,
            toTTSwapUINT256(157000 * 10 ** 6, 100 * 10 ** 18),
            _goodconfig,
            defaultdata
        );
        assertEq(
            address(market).balance,
            200 * 10 ** 18,
            "init3 metagood market eth error"
        );
        deal(reth, marketcreator, 1000 * 10 ** 18, false);
        rocketpoolmock(reth).approve(address(market), 100 * 10 ** 18);
        market.initMetaGood(
            reth,
            toTTSwapUINT256(157000 * 10 ** 6, 100 * 10 ** 18),
            _goodconfig,
            defaultdata
        );

        market.changeReStakingContrat(address(ttswapstake));

        deal(weth, marketcreator, 200 * 10 ** 18, false);
        MyToken(weth).approve(address(market), 100 * 10 ** 18);
        market.initMetaGood(
            sweth,
            toTTSwapUINT256(157000 * 10 ** 6, 100 * 10 ** 18),
            _goodconfig,
            defaultdata
        );
        vm.stopPrank();
    }

    function testStakeETH() public {
        vm.startPrank(marketcreator);
        assertEq(
            marketcreator.balance,
            800000000000000000000,
            "init  marketcreater eth error"
        );
        assertEq(
            address(market).balance,
            200000000000000000000,
            "init market eth error"
        );
        assertEq(address(reth).balance, 0, "init reth eth error");

        assertEq(
            ttswapstake.TotalState().amount0(),
            0,
            "1after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            0,
            "1after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            0,
            "1after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            0,
            "1after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            0,
            "1after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            0,
            "1after ttswapstake.TotalStake error"
        );
        market.stakeETH(seth, 10 * 10 ** 18);
        assertEq(
            ttswapstake.TotalState().amount0(),
            10000000000000000000,
            "2after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "2after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            10000000000000000000,
            "2after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "2after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            0,
            "2after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            10000000000000000000,
            "2after ttswapstake.TotalStake error"
        );
        assertEq(
            marketcreator.balance,
            800000000000000000000,
            "after stake eth error"
        );
        assertEq(address(market).balance, 190 * 10 ** 18, "after stake error");
        assertEq(address(reth).balance, 0, "after stake error");
        assertEq(
            address(ttswapstake).balance,
            10 * 10 ** 18,
            "after stake error"
        );

        assertEq(
            IERC20(reth).balanceOf(address(ttswapstake)),
            0,
            "after stake error"
        );
        ttswapstake.stakeRocketPoolETH(2 * 10 ** 18);
        assertEq(
            ttswapstake.TotalState().amount0(),
            10000000000000000000,
            "3after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "3after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            10000000000000000000,
            "3after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "3after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            2000000000000000000,
            "3after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            8000000000000000000,
            "3after ttswapstake.TotalStake error"
        );
        assertEq(
            marketcreator.balance,
            800000000000000000000,
            "after stake eth error"
        );
        assertEq(address(market).balance, 190 * 10 ** 18, "after stake error");
        assertEq(
            address(reth).balance,
            2000000000000000000,
            "after stake error"
        );
        assertEq(
            address(ttswapstake).balance,
            8 * 10 ** 18,
            "after stake error"
        );

        assertEq(
            IERC20(reth).balanceOf(address(ttswapstake)),
            2000000000000000000,
            "after stake error"
        );

        rocketpoolmock(reth).addreward{value: 1 * 10 ** 18}();
        assertEq(
            ttswapstake.TotalState().amount0(),
            10000000000000000000,
            "4after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "4after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            10000000000000000000,
            "4after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "4after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            2000000000000000000,
            "4after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            8000000000000000000,
            "4after ttswapstake.TotalStake error"
        );
        assertEq(
            address(reth).balance,
            3000000000000000000,
            "after reward error"
        );
        assertEq(
            marketcreator.balance,
            799000000000000000000,
            "after reward eth error"
        );

        assertEq(
            address(reth).balance,
            3000000000000000000,
            "after reward error"
        );
        assertEq(
            marketcreator.balance,
            799000000000000000000,
            "after reward eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            8000000000000000000,
            "after ttswapstake stake error"
        );
        assertEq(
            address(market).balance,
            190000000000000000000,
            "after stake market error"
        );

        market.syncReward(seth);

        assertEq(
            address(ttswapstake).balance,
            7000000000000000000,
            "after reth syncReward  ttswapstake error"
        );
        assertEq(
            address(market).balance,
            190888888888888888889,
            "after syncReward market error"
        );
        assertEq(
            address(reth).balance,
            3000000000000000000,
            "after reth syncReward error"
        );

        assertEq(
            marketcreator.balance,
            799111111111111111111,
            "after  syncReward  marketcreator eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            7000000000000000000,
            "after syncReward ttswapstake error"
        );
        assertEq(
            ttswapstake.TotalState().amount0(),
            9090909090909090910,
            "5after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "5after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            9090909090909090910,
            "5after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "5after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            3000000000000000000,
            "5after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            7000000000000000000,
            "5after ttswapstake.TotalStake error"
        );
        assertEq(
            address(reth).balance,
            3000000000000000000,
            "5after reth syncReward error"
        );

        rocketpoolmock(reth).addreward{value: 1 * 10 ** 18}();
        assertEq(
            address(market).balance,
            190888888888888888889,
            "66after syncReward market error"
        );
        assertEq(
            address(reth).balance,
            4000000000000000000,
            "66after reth syncReward error"
        );
        assertEq(
            marketcreator.balance,
            798111111111111111111,
            "66after  syncReward  marketcreator eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            7000000000000000000,
            "66after syncReward ttswapstake error"
        );
        assertEq(
            ttswapstake.TotalState().amount0(),
            9090909090909090910,
            "66after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "66after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            9090909090909090910,
            "66after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "66after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            3000000000000000000,
            "66after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            7000000000000000000,
            "66after ttswapstake.TotalStake error"
        );

        ttswapstake.unstakeRocketPoolETH(1 * 10 ** 18);

        assertEq(
            address(market).balance,
            190888888888888888889,
            "6after syncReward market error"
        );
        assertEq(
            address(reth).balance,
            2000000000000000000,
            "6after reth syncReward error"
        );
        assertEq(
            marketcreator.balance,
            798111111111111111111,
            "6after  syncReward  marketcreator eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            9000000000000000000,
            "6after syncReward ttswapstake error"
        );
        assertEq(
            ttswapstake.TotalState().amount0(),
            9090909090909090910,
            "6after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            12000000000000000000,
            "6after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            9090909090909090910,
            "6after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "6after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            1000000000000000000,
            "6after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            9000000000000000000,
            "6after ttswapstake.TotalStake error"
        );

        market.syncReward(seth);
        assertEq(
            address(market).balance,
            192666666666666666667,
            "7after syncReward market error"
        );
        assertEq(
            address(reth).balance,
            2000000000000000000,
            "7after reth syncReward error"
        );
        assertEq(
            marketcreator.balance,
            798333333333333333333,
            "7after  syncReward  marketcreator eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            7000000000000000000,
            "7after syncReward ttswapstake error"
        );
        assertEq(
            ttswapstake.TotalState().amount0(),
            7575757575757575759,
            "7after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            10000000000000000000,
            "7after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            7575757575757575759,
            "7after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            10000000000000000000,
            "7after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            1000000000000000000,
            "7after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            7000000000000000000,
            "7after ttswapstake.TotalStake error"
        );

        market.unstakeETH(seth, 1 * 10 ** 18);

        assertEq(
            address(market).balance,
            194555555555555555555,
            "8after syncReward market error"
        );
        assertEq(
            address(reth).balance,
            2000000000000000000,
            "8after reth syncReward error"
        );
        assertEq(
            marketcreator.balance,
            798444444444444444443,
            "8after  syncReward  marketcreator eth error"
        );
        assertEq(
            address(ttswapstake).balance,
            5000000000000000002,
            "8after syncReward ttswapstake error"
        );
        assertEq(
            ttswapstake.TotalState().amount0(),
            6818181818181818184,
            "8after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.TotalState().amount1(),
            9000000000000000002,
            "8after ttswapstake.TotalState error"
        );
        assertEq(
            ttswapstake.ethShare().amount0(),
            6818181818181818184,
            "8after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.ethShare().amount1(),
            9000000000000000002,
            "8after ttswapstake.ethShare error"
        );
        assertEq(
            ttswapstake.TotalStake().amount0(),
            1000000000000000000,
            "8after ttswapstake.TotalStake error"
        );
        assertEq(
            ttswapstake.TotalStake().amount1(),
            5000000000000000002,
            "8after ttswapstake.TotalStake error"
        );

        vm.stopPrank();
    }

    // function investOwnERC20ValueGood() public {
    //     vm.startPrank(marketcreator);
    //     market.investGood{value: 50000000000}(
    //         metagood,
    //         address(0),
    //         50000 * 10 ** 6,
    //         defaultdata,
    //         defaultdata
    //     );
    //     vm.stopPrank();
    // }

    // function testDistinvestProof() public {
    //     vm.startPrank(marketcreator);
    //     uint256 normalproof;
    //     normalproof = S_ProofKey(marketcreator, metagood, address(0)).toId();
    //     S_ProofState memory _proof = market.getProofState(normalproof);
    //     assertEq(
    //         _proof.state.amount0(),
    //         99995000000,
    //         "before disinvest:proof value error"
    //     );
    //     assertEq(
    //         _proof.invest.amount1(),
    //         99995000000,
    //         "before disinvest:proof quantity error"
    //     );

    //     assertEq(
    //         _proof.invest.amount0(),
    //         0,
    //         "before disinvest:proof contruct error"
    //     );

    //     S_GoodTmpState memory good_ = market.getGoodState(metagood);
    //     assertEq(
    //         good_.currentState.amount0(),
    //         99995000000,
    //         "before disinvest nativeeth good:metagood currentState amount0 error"
    //     );
    //     assertEq(
    //         good_.currentState.amount1(),
    //         99995000000,
    //         "before disinvest nativeeth good:metagood currentState amount1 error"
    //     );
    //     assertEq(
    //         good_.investState.amount0(),
    //         99995000000,
    //         "before disinvest nativeeth good:metagood investState amount0 error"
    //     );
    //     assertEq(
    //         good_.investState.amount1(),
    //         99995000000,
    //         "before disinvest nativeeth good:metagood investState amount1 error"
    //     );
    //     assertEq(
    //         good_.feeQuantityState.amount0(),
    //         5000000,
    //         "before disinvest nativeeth good:metagood feeQuantityState amount0 error"
    //     );
    //     assertEq(
    //         good_.feeQuantityState.amount1(),
    //         0,
    //         "before disinvest nativeeth good:metagood feeQuantityState amount1 error"
    //     );

    //     market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
    //     snapLastCall("disinvest_own_nativeeth_valuegood_first");
    //     good_ = market.getGoodState(metagood);
    //     assertEq(
    //         good_.currentState.amount0(),
    //         89995000000,
    //         "after disinvest nativeeth good:metagood currentState amount0 error"
    //     );
    //     assertEq(
    //         good_.currentState.amount1(),
    //         89995000000,
    //         "after disinvest nativeeth good:metagood currentState amount1 error"
    //     );
    //     assertEq(
    //         good_.investState.amount0(),
    //         89995000000,
    //         "after disinvest nativeeth good:metagood investState amount0 error"
    //     );
    //     assertEq(
    //         good_.investState.amount1(),
    //         89995000000,
    //         "after disinvest nativeeth good:metagood investState amount1 error"
    //     );
    //     assertEq(
    //         good_.feeQuantityState.amount0(),
    //         7499975,
    //         "after disinvest nativeeth good:metagood feeQuantityState amount0 error"
    //     );
    //     assertEq(
    //         good_.feeQuantityState.amount1(),
    //         0,
    //         "after disinvest nativeeth good:metagood feeQuantityState amount1 error"
    //     );

    //     _proof = market.getProofState(normalproof);
    //     assertEq(
    //         _proof.state.amount0(),
    //         89995000000,
    //         "after disinvest:proof value error"
    //     );
    //     assertEq(
    //         _proof.invest.amount1(),
    //         89995000000,
    //         "after disinvest:proof quantity error"
    //     );
    //     assertEq(
    //         _proof.invest.amount0(),
    //         0,
    //         "after disinvest:proof contruct error"
    //     );
    //     market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
    //     snapLastCall("disinvest_own_nativeeth_valuegood_second");

    //     market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
    //     snapLastCall("disinvest_own_nativeeth_valuegood_three");
    //     vm.stopPrank();
    // }
}
