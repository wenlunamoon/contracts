// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IWrapper is IERC20 {
  function deposit() external payable;
  function withdraw(uint wad) external;
}

contract Presale is Ownable, ReentrancyGuard {

  address public token;
  IWrapper internal native;
  address public treasury;
  uint256 public price;
  bool public open;

  constructor(address _treasury, address _token, address _native) {
    token = _token;
    treasury = _treasury;
    price = 0.0015 ether;
    open = true;
    native = IWrapper(_native);
  }

  function buy() external payable nonReentrant {
    uint256 amount = msg.value;
    native.deposit{value: amount}();
    uint count = amount/price;
    count *= 1 ether;
    require(count < IERC20(token).balanceOf(address(this))/100, "!too much");
    price = price * 10050 / 10000;
    native.transfer(owner(), amount/10);
    native.transfer(treasury, amount/10*9);
    IERC20(token).transfer(msg.sender, count);
  }

  function end() external onlyOwner {
    open = false;
    IERC20(token).transfer(treasury, IERC20(token).balanceOf(address(this)));
  }

  function changeTreasury(address _treasury) external onlyOwner {
    treasury = _treasury;
  }

  function remaining() external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

  // allows onwer to remove other Tokens from the Contract
  function inCaseTokensGetStuck(address _token) external onlyOwner {
    uint256 amount = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transfer(msg.sender, amount);
  }
} 