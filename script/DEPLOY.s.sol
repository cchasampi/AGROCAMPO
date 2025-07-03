// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {CCNFT} from "../src/CCNFT.sol";



contract DEPLOYCCNFT is Script {
address constant tokenAddress = 0x34abD99554eF53EDBA3B6AbEbB97DF2864Cfa07C ; // Reemplaza con la dirección del token ERC20   
function run() external {
    vm.startBroadcast();
    new CCNFT(tokenAddress);
    vm.stopBroadcast();
}
}
