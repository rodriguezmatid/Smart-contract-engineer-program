// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _res0, uint _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token0),
        "invalid token");
        if (_tokenIn == address(token0)) {
            token0.transferFrom(msg.sender, address(this), _amountIn);
            amountIn = token0.balanceOf(address(this)) - reserve0;
        } else {
            token1.transferFrom(msg.sender, address(this), _amountIn);
            amountIn = token0.balanceOf(address(this)) - reserve1;
        }
        // calculate amount out (including fees)
        // dx = dy ; 0.3% fee
        amountOut = (amountIn * 997)/1000;
        //update reserve 0 & reserve 1
        if (_tokenIn == address(token0)) {
            _update(reserve0 + _amountIn, reserve1 - amountOut);
        } else {
            _update(reserve0 - amountOut, reserve1 + amountIn);
        }

        // transfer token out
        if (_tokenIn == address(token0)) {
            token1.transfer(msg.sender, amountOut);
        } else {
            token0.transfer(msg.sender, amountOut);
        }
    }
    function addLiquidity() external {}
    function removeLiquidity() external {}
}