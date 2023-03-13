//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IUniswapV2Factory } from "./interfaces/IUniswapV2Factory.sol";
import { UniswapV2Pair } from "./UniswapV2Pair.sol";
import { IUniswapV2Pair } from "./interfaces/IUniswapV2Pair.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract UniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(UniswapV2Pair).creationCode));

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    uint256 public minAmountForDiscount;
    IERC20 public discountToken;

    constructor(address _feeToSetter, uint256 _minForDiscount, address _token) {
        feeToSetter = _feeToSetter;
        minAmountForDiscount = _minForDiscount;
        discountToken = IERC20(_token);
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function checkFee(address user) external view returns (bool) {
        return (discountToken.balanceOf(user) >= minAmountForDiscount);
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "UniswapV2: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        //solhint-disable-next-line no-inline-assembly
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    function setDiscountSettings(address _newToken, uint256 _amountForDiscount) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        discountToken = IERC20(_newToken);
        minAmountForDiscount = _amountForDiscount;
    }
}
