# TTSwap_Market
**Inherits:**
[I_TTSwap_Market](/src/interfaces/I_TTSwap_Market.sol/interface.I_TTSwap_Market.md), [I_TTSwap_LimitOrderTaker](/src/interfaces/I_TTSwap_LimitOrderTaker.sol/interface.I_TTSwap_LimitOrderTaker.md), IERC3156FlashLender

This contract handles initialization, buying, selling, investing, and disinvesting of goods and proofs.

*Manages the market operations for goods and proofs.*


## State Variables
### defaultdata

```solidity
bytes private constant defaultdata = abi.encode(L_CurrencyLibrary.S_transferData(1, "0X"));
```


### RETURN_VALUE

```solidity
bytes32 private constant RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");
```


### marketconfig

```solidity
uint256 public override marketconfig;
```


### goods

```solidity
mapping(address goodid => S_GoodState) internal goods;
```


### proofmapping

```solidity
mapping(uint256 proofkey => uint256 proofid) public override proofmapping;
```


### proofs

```solidity
mapping(uint256 proofid => S_ProofState) internal proofs;
```


### userConfig

```solidity
mapping(address => uint256) public override userConfig;
```


### marketcreator

```solidity
address public marketcreator;
```


### officialTokenContract

```solidity
address internal immutable officialTokenContract;
```


### officialNFTContract

```solidity
address internal immutable officialNFTContract;
```


### officelimitorder

```solidity
address internal immutable officelimitorder;
```


### securitykeeper

```solidity
address internal securitykeeper;
```


## Functions
### constructor

*Constructor for TTSwap_Market*


```solidity
constructor(
    uint256 _marketconfig,
    address _officialTokenContract,
    address _officialNFTContract,
    address _officelimitorder,
    address _marketcreator,
    address _securitykeeper
);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|The market configuration|
|`_officialTokenContract`|`address`|The address of the official contract|
|`_officialNFTContract`|`address`||
|`_officelimitorder`|`address`||
|`_marketcreator`|`address`||
|`_securitykeeper`|`address`||


### onlyDAOadmin


```solidity
modifier onlyDAOadmin();
```

### onlyMarketor


```solidity
modifier onlyMarketor();
```

### changemarketcreator


```solidity
function changemarketcreator(address _newmarketor) external;
```

### setMarketor


```solidity
function setMarketor(address _newmarketor) external override;
```

### removeMarketor


```solidity
function removeMarketor(address _user) external override;
```

### addbanlist

Adds an address to the ban list


```solidity
function addbanlist(address _user) external override onlyMarketor returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address to ban|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|is_success_ Success status|


### removebanlist

Removes an address from the ban list


```solidity
function removebanlist(address _user) external override onlyMarketor returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address to unban|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|is_success_ Success status|


### noReentrant


```solidity
modifier noReentrant();
```

### initMetaGood

Initialize the first good in the market

*Initializes a meta good*


```solidity
function initMetaGood(address _erc20address, uint256 _initial, uint256 _goodConfig, bytes memory data)
    external
    payable
    onlyDAOadmin
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_erc20address`|`address`|The address of the ERC20 token|
|`_initial`|`uint256`|The initial balance|
|`_goodConfig`|`uint256`|The good configuration|
|`data`|`bytes`|Configuration of the good|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Returns true if successful|


### initGood

Initialize a normal good in the market

*Initializes a good*


```solidity
function initGood(
    address _valuegood,
    uint256 _initial,
    address _erc20address,
    uint256 _goodConfig,
    bytes memory data1,
    bytes memory data2
) external payable override noReentrant returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_valuegood`|`address`|The value good ID|
|`_initial`|`uint256`|The initial balance|
|`_erc20address`|`address`|The address of the ERC20 token|
|`_goodConfig`|`uint256`|The good configuration|
|`data1`|`bytes`|Configuration of the good|
|`data2`|`bytes`|Configuration of the good|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Returns true if successful|


### buyGood

Sell one good to buy another

*Buys a good*


```solidity
function buyGood(
    address _goodid1,
    address _goodid2,
    uint128 _swapQuantity,
    uint256 _limitPrice,
    bool _istotal,
    address _referal,
    bytes memory data
) external payable noReentrant returns (uint128 goodid2Quantity_, uint128 goodid2FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`address`|The ID of the first good|
|`_goodid2`|`address`|The ID of the second good|
|`_swapQuantity`|`uint128`|The quantity to swap|
|`_limitPrice`|`uint256`|The limit price|
|`_istotal`|`bool`|Whether it's a total swap|
|`_referal`|`address`|The referral address|
|`data`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid2Quantity_`|`uint128`|The quantity of the second good received|
|`goodid2FeeQuantity_`|`uint128`|The fee quantity for the second good|


### takeLimitOrder


```solidity
function takeLimitOrder(S_takeGoodInputPrams memory _inputParams, uint96 _tolerance, address _takecaller)
    external
    payable
    override
    noReentrant
    returns (bool _isSuccess);
```

### _takeLimitOrder


```solidity
function _takeLimitOrder(S_takeGoodInputPrams memory _inputParams, uint96 _tolerance, address _takecaller)
    internal
    returns (bool _isSuccess);
```

### batchTakelimitOrder


```solidity
function batchTakelimitOrder(bytes calldata _inputData, uint96 _tolerance, address _takecaller, uint8 ordernum)
    external
    payable
    override
    noReentrant
    returns (bool[] memory);
```

### buyGoodForPay

Buy a good, sell another, and send to a recipient

*Buys a good for pay*


```solidity
function buyGoodForPay(
    address _goodid1,
    address _goodid2,
    uint128 _swapQuantity,
    uint256 _limitPrice,
    address _recipient,
    bytes memory data
) external payable override noReentrant returns (uint128 goodid1Quantity_, uint128 goodid1FeeQuantity_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid1`|`address`|The ID of the first good|
|`_goodid2`|`address`|The ID of the second good|
|`_swapQuantity`|`uint128`|The quantity to swap|
|`_limitPrice`|`uint256`|The limit price|
|`_recipient`|`address`|The recipient address|
|`data`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`goodid1Quantity_`|`uint128`|The quantity of the first good received|
|`goodid1FeeQuantity_`|`uint128`|The fee quantity for the first good|


### investGood

Invest in a normal good

*Invests in a good*


```solidity
function investGood(address _togood, address _valuegood, uint128 _quantity, bytes memory data1, bytes memory data2)
    external
    payable
    override
    noReentrant
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_togood`|`address`|The ID of the good to invest in|
|`_valuegood`|`address`|The ID of the value good|
|`_quantity`|`uint128`|The quantity to invest|
|`data1`|`bytes`||
|`data2`|`bytes`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Returns true if successful|


### disinvestProof

Disinvest from a normal good

*Disinvests a proof*


```solidity
function disinvestProof(uint256 _proofid, uint128 _goodQuantity, address _gater)
    public
    override
    noReentrant
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|The ID of the proof|
|`_goodQuantity`|`uint128`|The quantity of the good to disinvest|
|`_gater`|`address`|The gater address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool Returns true if successful|


### collectProof

Collect profit from an investment proof

*Collects the fee of a proof*


```solidity
function collectProof(uint256 _proofid, address _gater) external override noReentrant returns (uint256 profit_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_proofid`|`uint256`|The ID of the proof|
|`_gater`|`address`|The gater address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`profit_`|`uint256`|The collected profit|


### ishigher

Check if the price of a good is higher than a comparison price


```solidity
function ishigher(address goodid, address valuegood, uint256 compareprice) external view override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|ID of the good to check|
|`valuegood`|`address`|ID of the value good|
|`compareprice`|`uint256`|Price to compare against|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Whether the good's price is higher|


### getProofState


```solidity
function getProofState(uint256 proofid) external view override returns (S_ProofState memory);
```

### getGoodState


```solidity
function getGoodState(address goodkey) external view override returns (S_GoodTmpState memory);
```

### updateGoodConfig

Updates a good's configuration


```solidity
function updateGoodConfig(address _goodid, uint256 _goodConfig) external override returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The new configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### modifyGoodConfig

Allows market admin to modify a good's attributes


```solidity
function modifyGoodConfig(address _goodid, uint256 _goodConfig) external override onlyMarketor returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_goodConfig`|`uint256`|The new configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### payGood

Transfers a good to another address


```solidity
function payGood(address _goodid, uint128 _payquanity, address _recipent, bytes memory transdata)
    external
    payable
    override
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_payquanity`|`uint128`|The quantity to transfer|
|`_recipent`|`address`|The recipient's address|
|`transdata`|`bytes`|The recipient's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### changeGoodOwner

Changes the owner of a good


```solidity
function changeGoodOwner(address _goodid, address _to) external override onlyMarketor;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address`|The ID of the good|
|`_to`|`address`|The new owner's address|


### collectCommission

Collects commission for specified goods


```solidity
function collectCommission(address[] memory _goodid) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address[]`|Array of good IDs|


### queryCommission

Queries commission for specified goods and recipient


```solidity
function queryCommission(address[] memory _goodid, address _recipent)
    external
    view
    override
    returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_goodid`|`address[]`|Array of good IDs|
|`_recipent`|`address`|The recipient's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|Array of commission amounts|


### goodWelfare

Delivers welfare to investors


```solidity
function goodWelfare(address goodid, uint128 welfare, bytes memory data) external payable override noReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`goodid`|`address`|The ID of the good|
|`welfare`|`uint128`|The amount of welfare|
|`data`|`bytes`||


### setMarketConfig

Sets the market configuration


```solidity
function setMarketConfig(uint256 _marketconfig) external override onlyDAOadmin returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_marketconfig`|`uint256`|The new market configuration|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success status|


### delproofdata

*Internal function to handle proof data deletion and updates during transfer.*


```solidity
function delproofdata(uint256 proofid, address from, address to) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`proofid`|`uint256`|The ID of the proof being transferred.|
|`from`|`address`|The address transferring the proof.|
|`to`|`address`|The address receiving the proof.|


### maxFlashLoan

*The amount of currency available to be lended.*


```solidity
function maxFlashLoan(address good) public view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`good`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of `token` that can be borrowed.|


### flashFee

*The fee to be charged for a given loan.*


```solidity
function flashFee(address token, uint256 amount) public view override returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The loan currency.|
|`amount`|`uint256`|The amount of tokens lent.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The amount of `token` to be charged for the loan, on top of the returned principal.|


### flashLoan


```solidity
function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data)
    public
    override
    returns (bool);
```

### flashLoan1


```solidity
function flashLoan1(
    IERC3156FlashBorrower receiver,
    address token,
    uint256 amount,
    bytes calldata data,
    bytes memory transdata
) public override returns (bool);
```

### securityKeeper


```solidity
function securityKeeper(address token, uint256 amount) external;
```

### removeSecurityKeeper


```solidity
function removeSecurityKeeper() external;
```

## Errors
### ERC3156UnsupportedToken
*The loan token is not valid.*


```solidity
error ERC3156UnsupportedToken(address token);
```

### ERC3156ExceededMaxLoan
*The requested loan exceeds the max loan value for `token`.*


```solidity
error ERC3156ExceededMaxLoan(uint256 maxLoan);
```

### ERC3156InvalidReceiver
*The receiver of a flashloan is not a valid [IERC3156FlashBorrower-onFlashLoan](/lib/openzeppelin-contracts/contracts/mocks/ERC3156FlashBorrowerMock.sol/contract.ERC3156FlashBorrowerMock.md#onflashloan) implementer.*


```solidity
error ERC3156InvalidReceiver(address receiver);
```

