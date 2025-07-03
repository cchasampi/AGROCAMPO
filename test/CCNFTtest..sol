// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {CCNFT} from "../src/CCNFT.sol";

contract CCNFTTEST is Test {
    CCNFT public ccNFT;

    address public constant NTF_ADDRESS = 0x5a939425C4F35cCF78Db5FCc2711a8e9036a325F;
    function setUp() public {
        ccNFT = new CCNFT(NTF_ADDRESS); // Inicializamos el contrato CCNFT con la dirección del contrato desplegado
    }

    function testCCNFT() public {
        vm.startPrank(NTF_ADDRESS); // Simulamos que el usuario es quien llama a la función
        ccNFT.buy(200000000000000000000, 4); // Acuñamos un NFT con el URI del estado feliz
       console.log('token buy'  ); // Verificamos que la URI del token 0 sea la esperada
        assert(ccNFT.balanceOf(NTF_ADDRESS) == 4); // Verificamos que el balance del usuario sea 4

}
}