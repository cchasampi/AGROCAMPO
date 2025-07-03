// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CCNFT} from "../src/CCNFT.sol";

contract BUYNFT is Script { 
    
    function run() external {

        address contractAddress = 0x5a939425C4F35cCF78Db5FCc2711a8e9036a325F   ; //dir del contrato desplegado // darle permiso
         
         // Reemplaza con la dirección del contrato desplegado
        buyOnContract(contractAddress);
    }

    function buyOnContract( address contractAdsress) public {
        vm.startBroadcast();   
        CCNFT(contractAdsress).buy(400000000000000000000,4); // Llamamos a la función buy con el valor y la cantidad deseada
        vm.stopBroadcast();
        }

}


contract PUTNFT is Script { 
    
    function run() external {
        address contractAdsress = 0x5a939425C4F35cCF78Db5FCc2711a8e9036a325F     ; //aqui va la dir del contrato desplegado
        
         // Reemplaza con la dirección del contrato desplegado
        putOnContract(contractAdsress);
    }

    function putOnContract( address contractAdsress ) public {
        vm.startBroadcast();   
        CCNFT(contractAdsress).putOnSale(4, 400000000000000000000); // Llamamos a la función buy con el valor y la cantidad deseada
        vm.stopBroadcast();
        }

}



contract TRADENFT is Script { 
    
    function run() external {
 
     address contractAddress = 0x5a939425C4F35cCF78Db5FCc2711a8e9036a325F   ; //aqui va la dir del contrato desplegado
     
         // Reemplaza con la dirección del contrato desplegado
        tradetOnContract(contractAddress );
    }

    function tradetOnContract( address contractAddress) public {
        vm.startBroadcast();   
        CCNFT(contractAddress).trade(4); // Llamamos a la función trade con el tokenid
        vm.stopBroadcast();
        }

}


contract CLAIMNFT is Script { 
    
    function run() external {

     address contractAddress = 0x5a939425C4F35cCF78Db5FCc2711a8e9036a325F   ; //aqui va la dir del contrato desplegado
     
         // Reemplaza con la dirección del contrato desplegado
        claimOnContract(contractAddress );
    }

    function claimOnContract( address contractAddress  ) public {
        vm.startBroadcast();   
        CCNFT(contractAddress).claim(2); // Llamamos a la función claim con el tokenid
        console.log("NFT reclamado exitosamente");
        vm.stopBroadcast();
        }

}


