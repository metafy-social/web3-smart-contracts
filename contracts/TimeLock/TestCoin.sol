// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract TestCoin is ERC20 {
  constructor() ERC20('Test Coin', 'TCK') {
    _mint(msg.sender, 20 * 10 ** 18);
  }
}
