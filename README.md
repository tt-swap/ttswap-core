# TTSWAP
TTSWAP (token-token swap) protocol is a decentralized automated market-making protocol built on the EVM blockchain. Its underlying principle is based on the transfer of market value triggered by user behavior, and it constructs a platform using value conservation trading strategies.
The whitepaper explains the design logic of the ttswap project, covering principles and implementations of goods trading, investment, and withdrawal of value goods, as well as ordinary goods investment and withdrawal, and the generation and distribution of goods transaction fees.

## Features
***Value Conservation Trading Strategy***
The value conservation trading strategy accurately reflects the true market value of currencies and facilitates fast goods transactions.

1. Direct Trading without Intermediaries
On this platform, any two types of items can be directly traded without the need for intermediate conversions.

2. No Slippage within Trading Threshold
Transactions below the goods trading threshold incur no slippage.

3. No Impermanent Loss for Liquidity Providers or goods Investors
Constant market value inherently prevents impermanent loss. When users withdraw their investment, they receive the original invested goods plus profits generated from providing liquidity.

4. Low Gas Fees with Simple Computational Logic
The logic behind the constant value trading model is simple, resulting in low computational load and gas consumption.

5. Fee Distribution Based on Roles for Everyone
Fees are distributed based on roles, allowing anyone to become a goods investor (liquidity provider), goods seller, gater, referrer, user, or platform role, sharing in the platform's growth earnings.

6. Support Native ETH Exchange and Invest
anyone can you native ETH without wrap to swap, invest easily.

7. Community-Driven Developement and Innovation
ttswap emphasizes a community-driven approach to development and innovation. Since its code release, there has been active community engagement, with many issues, pull requests, and unique feature ideas contributed by users. The protocol is designed to encourage innovation, allowing the global community to shape the future of AMMs.
## Contributing

If you’re interested in contributing please see our [contribution guidelines](./CONTRIBUTING.md)!

## Whitepaper

A more detailed description of ttswap Core can be found in the draft of the [TTSWAP Core Whitepaper-en](./docs/whitepaper_en.pdf) |[TTSWAP Core Whitepaper-cn](./docs/whitepaper_cn.pdf).   

## Architecture

`ttswap-core` uses a singleton-style architecture, where all goods state is managed in the `MarketManager.sol` contract.

the contract devide four part:

Part 1: the action relate to good'initial ,goods investing (stake or add liquidity),goods disinvestint (unstake or remove liquidity),goods swaping , or disinvesting proof ( burn stake proof or liquidity position )  are defined in marketmanager.sol.

Part 2: the action relate goods config , collect fee of goods , good's attribute defined in goodmanage.sol.

Part 3: because proof is ERC721 standard, and it's define in proofmanage.sol

## Repository Structure && License

All contracts are held within the `ttswap-core/Contracts` folder.

Note  but all foundry tests are in the `ttswap-core/test` folder.

```markdown
Contract
├── GoodManage.sol(BUSL-1.1)  
├── MarketManager.sol(BUSL-1.1)  
├── ProofManage.sol(BUSL-1.1)  
├── interfaces  
│   ├── I_Good.sol(MIT)  
│   ├── I_MarketManage.sol(MIT)  
│   └── I_Proof.sol(MIT)   
└── libraries      
   ├── L_Good.sol(BUSL-1.1)    
   ├── L_GoodConfig.sol(MIT)     
   ├── L_MarketConfig.sol(MIT)    
   ├── L_Proof.sol(BUSL-1.1)   
   ├── T_BalanceUINT256.sol (MIT)     
   ├── T_Currency.sol (MIT)       
   ├── L_Struct.sol (MIT)     
   └── L_ArrayStorage.sol(MIT)    
docs
├── ebook
├── whitepaper-cn
│   └──whitepaper-cn.pdf(BUSL-1.1)
└── whitepaper-en
    └──whitepaper-en.pdf(BUSL-1.1)
tests

```
The primary license for ttswap-core is the Business Source License 1.1 (`BUSL-1.1`), see [LICENSE](https://github.com/tt-swap/ttswap-core/blob/main/LICENSE).

## Everyone Can be Gater

To utilize the contracts and deploy to a local testnet, you can install the code in your repo with forge:

```markdown
forge install https://github.com/tt-swap/ttswap-core
```

To integrate with the contracts, the interfaces are available to use:

```solidity

import {I_MarketManager} from 'ttswap-core/contracts/interfaces/I_MarketManager.sol';

contract MyPortal  {
    I_MarketManager marketManager;
    address IamGater

    function doThing () {
        marketManager.buyGood(...);
        marketManager.buyGoodForPay(...);
        marketManager.initGood(...);
        marketManager.investGood(...);
        marketManager.disinvestProof(....,IamGater,referal);
        marketManager.collectProof(....,IamGater,referal);
        ....
    }
}

```
## User deploy local instruction
step 1:instrall forge  
step 2:forge install OpenZeppelin/openzeppelin-contracts@v4.9.6  
step 3:forge install marktoda/forge-gas-snapshot  


## Socials / Contract
Twitter:[ttswap_exchange](https://x.com/ttswap_exchange)  
Telegram:[@ttswap01](https://t.me/ttswap01)  
Email:[ttswap.exchange@gmail.com](mailto:ttswap.exchange@gmail.com)  
Discord:[ttswap](https://discord.gg/5PhXn9DR)  
Website:[tt-swap.com](http://www.ttswap.io)  
