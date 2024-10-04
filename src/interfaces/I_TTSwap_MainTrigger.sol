// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface I_TTSwap_MainTrigger {
    function setofficialMarket(address _officialMarket) external;
    /**
     * @dev external function will be called before the good is seld
     * @param triggercontract The triger address  of the good
     * @param opgood The ID of the oppent good being swaped.
     * @param trade the amount of sell of current  good
     * @param currentstate the good state of current good.
     * @param opstate  the good state of oppent good.
     * @param recipent The address who call the transaction.
     * @return  true:will interupt the transaction
     */
    function main_swaptake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);
    /**
     * @dev external function will be called before the good is bought
     * @param triggercontract The triger address  of the good
     * @param opgood The ID of the current good being swaped.
     * @param trade the amount of buy of oppent  good
     * @param currentstate the good state of current good.
     * @param opstate  the good state of oppent good.
     * @param recipent The address who call the transaction.
     * @return  true:will interupt the transaction
     */
    function main_swapmake(
        address triggercontract,
        uint256 opgood,
        uint256 trade,
        uint256 currentstate,
        uint256 opstate,
        address recipent
    ) external returns (bool);
    /**
     * @dev external function will be called before the good is invested
     * @param triggercontract The triger address  of the good
     * @param investquanity the invest amount of the good
     * @param currentstate the current state ofgood
     * @param recipent The address who call the transaction.
     * @return  true:will interupt the transaction
     */
    function main_invest(
        address triggercontract,
        uint256 investquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);
    /**
     * @dev external function will be called before the good is divested
     * @param triggercontract The triger address  of the good
     * @param divestquanity the divest amount of the good.
     * @param currentstate the current state ofgood
     * @param recipent The address who call the transaction.
     * @return  true:will interupt the transaction
     */
    function main_divest(
        address triggercontract,
        uint256 divestquanity,
        uint256 currentstate,
        address recipent
    ) external returns (bool);
}
