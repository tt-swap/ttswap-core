// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/libraries/L_Struct.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_CurrencyLibrary} from "../src/libraries/L_Currency.sol";
import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {ProofUtil} from "./util/ProofUtil.sol";
import {GoodUtil} from "./util/GoodUtil.sol";

contract testBuy11 is Test {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofKeyLibrary for S_ProofKey;
    using L_CurrencyLibrary for address;
    using L_TTSwapUINT256Library for uint256;
    using L_Good for L_Good.S_GoodState;

    uint256 usdtgood;
    uint256 nativenormalgood;
    uint256 btcgood;
    uint256 ethgood;
    uint256 normalgoodusdt;
    uint256 metaproofid;
    address marketcreator;

    MyToken usdt;
    MyToken eth;
    MyToken wbtc;
    L_Good.S_GoodState ethstate;

    L_Good.S_GoodState btcstate;

    function setUp() public {
        marketcreator = address(1);
        vm.startPrank(marketcreator);
        usdt = new MyToken("USDT", "USDT", 6);
        wbtc = new MyToken("BTC", "BTC", 8);
        eth = new MyToken("ETH", "ETH", 18);
        ethstate.init(
            toTTSwapUINT256(3991740104749, 830576621067531951132),
            address(eth),
            574294852927029179450682055812555939397509459020590716783642472657759240192
        );

        btcstate.init(
            toTTSwapUINT256(2549265184202, 6171481752),
            address(wbtc),
            574294852927029179450682055812555939397509459020590716783642472657759240192
        );
        vm.stopPrank();
    }
    function testBuyfromethtobtc() public view {
        uint128 swap = 10 * 10 ** 18;

        L_Good.swapCache memory swapcache = L_Good.swapCache({
            remainQuantity: swap,
            outputQuantity: 0,
            feeQuantity: 0,
            swapvalue: 0,
            good1currentState: ethstate.currentState,
            good1config: ethstate.goodConfig,
            good2currentState: btcstate.currentState,
            good2config: btcstate.goodConfig
        });
        uint256 _limitPrice = toTTSwapUINT256(1, 1); //301099450000000000000
        _limitPrice = 3402823669209384634633746074317682114560000000009; //301099450000000000000

        swapcache = L_Good.swapCompute1(swapcache, _limitPrice);
        console2.log("1", swapcache.remainQuantity);
        console2.log("2", swapcache.outputQuantity);
    }
}
