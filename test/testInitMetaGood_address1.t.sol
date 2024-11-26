// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";

import {L_ProofKeyLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256} from "../src/libraries/L_TTSwapUINT256.sol";

import {ERC20PermitTest} from "../src/ERC20PermitTest.sol";
contract testInitMetaGood_address1 is BaseSetup {
    using L_ProofKeyLibrary for S_ProofKey;
    using L_GoodIdLibrary for S_GoodKey;
    using L_TTSwapUINT256Library for uint256;
    address metagood;

    ERC20PermitTest internal kkkk;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;
    function setUp() public override {
        BaseSetup.setUp();
        kkkk = new ERC20PermitTest("USDT", "USDT");
        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);
    }

    function testinitNativeMetaGoodaddress1() public {
        vm.startPrank(marketcreator);
        address nativeCurrency = address(0);
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
    struct S_Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }
    function testinitMetaGoodtype2() public {
        vm.startPrank(owner);
        uint256 goodconfig = 2 ** 255;
        deal(address(kkkk), owner, 100000, false);
        L_CurrencyLibrary.S_transferData memory tt = L_CurrencyLibrary
            .S_transferData(2, "");
        bytes memory bb = abi.encode(tt);
        L_CurrencyLibrary.S_transferData memory _simplePermit = abi.decode(
            bb,
            (L_CurrencyLibrary.S_transferData)
        );
        bytes32 _DOMAIN_SEPARATOR = kkkk._domainSeparatorV4();
        S_Permit memory permit = S_Permit({
            owner: owner,
            spender: address(this),
            value: 100e18,
            nonce: 0,
            deadline: 1 days
        });

        bytes32 structhash = keccak256(
            abi.encode(
                permit.owner,
                permit.spender,
                permit.value,
                permit.nonce,
                permit.deadline
            )
        );

        bytes32 digest = kkkk._hashTypedDataV4(structhash);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        kkkk.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(kkkk.allowance(marketcreator, address(this)), 1e18);
        assertEq(kkkk.nonces(marketcreator), 1);
        vm.stopPrank();
    }
}
