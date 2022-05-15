// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale is Ownable {

  address public token;
  address public treasury;
  uint256 public price;
  bool public open;
  uint256 public maxAllocPerAddress;

  constructor(address _treasury, address _token) {
    token = _token;
    treasury = _treasury;
    price = 0.0015 ether;
    open = true;
    maxAllocPerAddress = 10 ** 18 * 30000 + 1;
  }

  function buy() external payable {
    require(IERC20(token).balanceOf(msg.sender) < maxAllocPerAddress, "!too much allocation");
    uint256 count = 10 ** 18 * msg.value / price;
    require(count < maxAllocPerAddress/2, "!buying too much");
    uint256 fee = msg.value / 10;
    price = price * 10050 / 10000;
    payable(owner()).transfer(fee);
    payable(treasury).transfer(msg.value/10*9);
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