// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface BeefyUniV2Zap {
    function beefInETH (address beefyVault, uint256 tokenAmountOutMin) external payable;
}

contract YieldGen {
    address private constant BEEFY_UNIV2ZAP = 0x540A9f99bB730631BF243a34B19fd00BA8CF315C;
    address private constant BEEFY_VAULTv6 = 0xdb15F201529778b5e2dfa52D41615cd1AB24c765;
    address public manager;
    constructor() {
        manager = msg.sender;
    }
    function addMoney() payable public {
        require(
            msg.value > 0 * 1 ether, 
            "You must send some ether"
        );
    }

    function stake(uint256 val, uint256 token) payable public {
        require(
            msg.sender == manager, 
            "You must be the manager to withdraw"
        );
        BeefyUniV2Zap(payable(BEEFY_UNIV2ZAP)).beefInETH{value: val, gas: 35000000000}(
            BEEFY_VAULTv6,
            token
        );
    }

    function withdraw() public {
        require(
            msg.sender == manager, 
            "You must be the manager to withdraw"
        );
        payable(manager).transfer(address(this).balance);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}