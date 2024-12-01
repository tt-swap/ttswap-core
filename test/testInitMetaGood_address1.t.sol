// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {TTSwap_Token} from "../src/TTSwap_Token.sol";
import {TTSwap_Market} from "../src/TTSwap_Market.sol";
import {TTSwap_NFT} from "../src/TTSwap_NFT.sol";
import {TTSwap_LimitOrder} from "../src/TTSwap_LimitOrder.sol";

import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256} from "../src/libraries/L_TTSwapUINT256.sol";
import "forge-gas-snapshot/GasSnapshot.sol";
contract testInitMetaGood_address1 is Test, GasSnapshot {
    using L_ProofKeyLibrary for S_ProofKey;
    using L_GoodIdLibrary for S_GoodKey;
    using L_TTSwapUINT256Library for uint256;
    using ECDSA for bytes32;
    address metagood;

    MyToken internal kkkk;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;
    uint256 internal marketcreatorkey;

    bytes32 private _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    address payable[8] internal users;
    MyToken btc;
    MyToken usdt;
    MyToken eth;
    address marketcreator;
    TTSwap_Market market;
    TTSwap_Token tts_token;
    TTSwap_NFT tts_nft;
    TTSwap_LimitOrder tts_limitorder;
    bytes internal constant defaultdata =
        abi.encode(L_CurrencyLibrary.S_transferData(1, ""));
    event debuggdata(bytes);

    function setUp() public virtual {
        marketcreatorkey = 0xA121;
        marketcreator = vm.addr(marketcreatorkey);
        uint256 m_marketconfig = (45 << 250) +
            (5 << 244) +
            (10 << 238) +
            (15 << 232) +
            (25 << 226) +
            (20 << 220);

        users[0] = payable(address(1));
        users[1] = payable(address(2));
        users[2] = payable(address(3));
        users[3] = payable(address(4));
        users[4] = payable(address(5));
        users[5] = payable(address(15));
        users[6] = payable(address(16));
        users[7] = payable(address(17));
        btc = new MyToken("BTC", "BTC", 8);
        usdt = new MyToken("USDT", "USDT", 6);
        eth = new MyToken("ETH", "ETH", 18);
        vm.startPrank(marketcreator);
        tts_token = new TTSwap_Token(address(usdt), marketcreator, 2 ** 255);
        tts_nft = new TTSwap_NFT(address(tts_token));
        tts_limitorder = new TTSwap_LimitOrder(marketcreator);
        snapStart("depoly Market Manager");
        market = new TTSwap_Market(
            m_marketconfig,
            address(tts_token),
            address(tts_nft),
            address(tts_limitorder),
            marketcreator,
            marketcreator
        );
        snapEnd();
        tts_token.addauths(address(market), 1);
        tts_token.addauths(marketcreator, 3);
        kkkk = new MyToken("USDT", "USDT", 6);

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);
    }
    struct SimplePermit {
        uint8 transfertype;
        bytes detail;
    }
    function testinitNativeMetaGoodaddress1() public {
        vm.startPrank(marketcreator);
        address nativeCurrency = address(1);
        uint256 goodconfig = 2 ** 255;
        vm.deal(marketcreator, 100000 * 10 ** 6);
        assertEq(
            marketcreator.balance,
            100000 * 10 ** 6,
            "before initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            0,
            "before initial metagood:market account initial balance error"
        );

        market.initMetaGood{value: 50000 * 10 ** 6}(
            nativeCurrency,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig,
            defaultdata
        );
        snapLastCall("init_nativeerc20_metagood");
        metagood = nativeCurrency;
        assertEq(
            marketcreator.balance,
            100000 * 10 ** 6 - 50000 * 10 ** 6,
            "after initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            address(market).balance,
            50000 * 10 ** 6,
            "after initial metagood:market account initial balance error"
        );

        S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            good_.investState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            good_.feeQuantityState,
            0,
            "after initial metagood:metagood feequnitity error"
        );

        assertEq(
            good_.goodConfig,
            2 ** 255,
            "after initial metagood:metagood goodConfig error"
        );

        assertEq(
            good_.owner,
            marketcreator,
            "after initial metagood:metagood marketcreator error"
        );

        uint256 metaproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, address(0)).toKey()
        );
        S_ProofState memory _proof1 = market.getProofState(metaproof);
        assertEq(
            _proof1.state.amount0(),
            50000 * 10 ** 6,
            "after initial:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            50000 * 10 ** 6,
            "after initial:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after initial:proof quantity error"
        );
        assertEq(
            tts_nft.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            tts_nft.ownerOf(metaproof),
            marketcreator,
            "erc721 proof owner error"
        );
        vm.stopPrank();
    }

    function testinitMetaGoodtype1() public {
        vm.startPrank(marketcreator);
        uint256 goodconfig = 2 ** 255;
        usdt.mint(marketcreator, 100000);
        usdt.approve(address(market), 50000 * 10 ** 6);

        assertEq(
            usdt.balanceOf(marketcreator),
            100000 * 10 ** 6,
            "before initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            0,
            "before initial metagood:market account initial balance error"
        );

        market.initMetaGood(
            address(usdt),
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            goodconfig,
            defaultdata
        );
        snapLastCall("init_erc20_metagood");
        metagood = address(usdt);
        assertEq(
            usdt.balanceOf(marketcreator),
            100000 * 10 ** 6 - 50000 * 10 ** 6,
            "after initial metagood:marketcreator account initial balance error"
        );
        assertEq(
            usdt.balanceOf(address(market)),
            50000 * 10 ** 6,
            "after initial metagood:market account initial balance error"
        );

        assertEq(
            market.getGoodState(metagood).currentState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood currentState error"
        );
        assertEq(
            market.getGoodState(metagood).investState,
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            "after initial metagood:metagood investState error"
        );
        assertEq(
            market.getGoodState(metagood).feeQuantityState,
            0,
            "after initial metagood:metagood feequnitity error"
        );

        assertEq(
            market.getGoodState(metagood).goodConfig,
            2 ** 255,
            "after initial metagood:metagood goodConfig error"
        );

        assertEq(
            market.getGoodState(metagood).owner,
            marketcreator,
            "after initial metagood:metagood marketcreator error"
        );

        uint256 metaproof = market.proofmapping(
            S_ProofKey(marketcreator, metagood, address(0)).toKey()
        );
        S_ProofState memory _proof1 = market.getProofState(metaproof);
        assertEq(
            _proof1.state.amount0(),
            50000 * 10 ** 6,
            "after initial:proof value error"
        );
        assertEq(
            _proof1.invest.amount1(),
            50000 * 10 ** 6,
            "after initial:proof quantity error"
        );
        assertEq(
            _proof1.valueinvest.amount1(),
            0,
            "after initial:proof quantity error"
        );

        assertEq(
            tts_nft.balanceOf(marketcreator),
            1,
            "erc721 market balance error"
        );

        assertEq(
            tts_nft.ownerOf(metaproof),
            marketcreator,
            "erc721 proof owner error"
        );

        vm.stopPrank();
    }

    function testERC20permit() public {
        deal(address(kkkk), owner, 100000, false);
        uint256 bltim = block.timestamp;

        bytes32 structHash = keccak256(
            abi.encode(_PERMIT_TYPEHASH, owner, spender, 1024, 0, bltim)
        );

        bytes32 digest = kkkk.DOMAIN_SEPARATOR().toTypedDataHash(structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.startPrank(spender);
        assertEq(kkkk.allowance(owner, spender), 0);
        assertEq(kkkk.nonces(owner), 0);
        kkkk.permit(owner, spender, 1024, bltim, v, r, s);
        vm.sleep(1);
        assertEq(kkkk.nonces(owner), 1);
        assertEq(kkkk.allowance(owner, spender), 1024);

        assertEq(0, kkkk.balanceOf(users[2]), "before trnasferform error");
        kkkk.transferFrom(owner, users[2], 1000);
        assertEq(1000, kkkk.balanceOf(users[2]), "after trnasferform error");
        vm.stopPrank();
    }

    function testERC20permitinitmetagood() public {
        deal(address(kkkk), marketcreator, 50000 * 10 ** 7, false);
        uint256 bltim = block.timestamp + 10000;
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                marketcreator,
                address(market),
                50000 * 10 ** 6,
                0,
                bltim
            )
        );

        bytes32 digest = kkkk.DOMAIN_SEPARATOR().toTypedDataHash(structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(marketcreatorkey, digest);
        //kkkk.permit(owner, address(this), 100e18, 1 days, v, r, s);

        S_Permit2 memory ef = S_Permit2(
            marketcreator,
            //address(market),
            50000 * 10 ** 6,
            bltim,
            v,
            r,
            s
        );

        SimplePermit memory sp = SimplePermit(2, abi.encode(ef));
        vm.startPrank(marketcreator);
        market.initMetaGood(
            address(kkkk),
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            2 ** 255,
            abi.encode(sp)
        );
        vm.stopPrank();
    }

    struct S_Permit2 {
        address owner;
        // address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}
