// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";

contract BeradexStaking is ERC20("xBeradex", "xBRDX"){
    using SafeMath for uint256;
    IERC20 public beradex;

    // Define the beradex token contract
    constructor(IERC20 _beradex) public {
        beradex = _beradex;
    }

    // Enter the bar. Pay some beradexs. Earn some shares.
    // Locks beradex and mints xberadex
    function enter(uint256 _amount) public {
        // Gets the amount of beradex locked in the contract
        uint256 totalBrdx = beradex.balanceOf(address(this));
        // Gets the amount of xberadex in existence
        uint256 totalShares = totalSupply();
        // If no xberadex exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalBrdx == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xberadex the beradex is worth. The ratio will change overtime, as xberadex is burned/minted and beradex deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalBrdx);
            _mint(msg.sender, what);
        }
        // Lock the beradex in the contract
        beradex.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your beradexs.
    // Unlocks the staked + gained beradex and burns xberadex
    function leave(uint256 _share) public {
        // Gets the amount of xberadex in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of beradex the xberadex is worth
        uint256 what = _share.mul(beradex.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        beradex.transfer(msg.sender, what);
    }
}