//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";

// @i_like_cubes
contract WLM is ERC20, ReentrancyGuard, Ownable {
    address public donationpool;
    uint256 internal price;
    uint256 internal maxsupply;
    uint256 internal presaleend;
    bool internal presale = true;

    constructor(address pool, uint256 supplyWholeTokens)
        ERC20("WEN LUNA MOON", "WLM")
    {
        donationpool = pool;
        _mint(msg.sender, (supplyWholeTokens * 10**18) / 4);
        maxsupply = supplyWholeTokens * 10**18;
        presaleend = block.timestamp + 24 hours;
        price = 0.001 ether;
    }

    function buyPresale() external payable nonReentrant {
        require(presale, "Presale finished");
        uint256 count = 10**18 * (msg.value / price);
        require(
            ERC20(address(this)).balanceOf(msg.sender) <= maxsupply / 30,
            "You are not allowed to presale buy more then 3% of the supply"
        );
        require(totalSupply() + count < maxsupply, "Not enough supply left");
        require(
            count < maxsupply / 100,
            "you can only buy 1% of supply at once"
        );
        payable(donationpool).transfer(msg.value / 2);
        payable(owner()).transfer(msg.value / 2);
        price = (price * 10050) / 10000;
        _mint(msg.sender, count);
    }

    function finishPresale() external onlyOwner {
        if (block.timestamp >= presaleend) {
            presale = false;
        }
        require(!presale, "Still in presale");
        // moving tokens to owner for further distriibution (staking)
        _mint(owner(), maxsupply - totalSupply());
    }

    function donate() external payable nonReentrant {
        uint256 fee = msg.value / 5;
        payable(owner()).transfer(fee);
        payable(donationpool).transfer(msg.value - fee);
    }

    function presalePrice() external view returns (uint256) {
        return price;
    }

    function maxSupply() external view returns (uint256) {
        return maxsupply;
    }

    function presaleEnd() external view returns (uint256) {
        return presaleend;
    }

    function isInPresale() external view returns (bool) {
        return presale;
    }

    function changePool(address pool) external onlyOwner {
        donationpool = pool;
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(this), "!token");
        uint256 amount = IERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(msg.sender, amount);
    }
}
