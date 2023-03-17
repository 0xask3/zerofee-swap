// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";

import { UniswapV2Factory } from "../src/core/UniswapV2Factory.sol";
import { UniswapV2Router02 } from "../src/peripheral/UniswapV2Router02.sol";
import { WETH } from "../src/WETH.sol";

contract Deploy is Script {
    function run() external {
        string memory mnemonic = vm.envString("MNEMONIC");
        uint256 privKey = vm.deriveKey(mnemonic, 0);
        vm.startBroadcast(privKey);

        WETH weth = new WETH();
        UniswapV2Factory factory = new UniswapV2Factory(msg.sender, 100 ether, 0x77c21c770Db1156e271a3516F89380BA53D594FA);
        new UniswapV2Router02(address(factory), address(weth));

        vm.stopBroadcast();
    }
}
