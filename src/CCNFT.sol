// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/Counters.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

contract CCNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    
 event Buy(address indexed buyer, uint256 indexed tokenId, uint256 valorcito); 

 event Claim(address indexed buyer, uint256 indexed tokenId);

 event Trade(address indexed from, address indexed to ,uint256 indexed tokenId, uint256 valorcito);
 event PutOnSale( uint256 indexed tokenId, uint256 price);

   
struct TokenSale {
        bool onSale;
        uint256 valorcito;
    }


// Biblioteca Counters de OpenZeppelin para manejar contadores de manera segura.
using Counters for Counters.Counter; 

Counters.Counter private tokenIdTracker;

mapping(uint256 => uint256) public valorcitos;

mapping(uint256 => bool) public validvalorcitos;

mapping(uint256 => TokenSale) public tokensOnSale;

uint256[] public listTokensOnSale;
    
address public fundsCollector; // Dirección de los fondos de las ventas de los NFTs
address public feesCollector; // Dirección de las tarifas de transacción (compra y venta de los NFTs)

bool public canBuy; // Booleano que indica si las compras de NFTs están permitidas.
bool public canClaim; // Booleano que indica si la reclamación (quitar) de NFTs está permitida.
bool public canTrade; // Booleano que indica si la transferencia de NFTs está permitida.

uint256 public totalvalorcito; // Valor total acumulado de todos los NFTs en circulación.
uint256 public maxvalorcitoToRaise; // Valor máximo permitido para recaudar a través de compras de NFTs.

uint16 public buyFee; // Tarifa aplicada a las compras de NFTs.
uint16 public tradeFee; // Tarifa aplicada a las transferencias de NFTs.
    
uint16 public maxBatchCount; // Límite en la cantidad de NFTs por operación (evitar exceder el límite de gas en una transacción).

uint32 public profitToPay; // Porcentaje adicional a pagar en las reclamaciones.

IERC20 public fundsToken;
//
// Constructor del contrato
constructor(address _tokenAddress) ERC721("CCNFT", "CCNFT") {

    fundsCollector = 0x8D6051dEdbE3B08590674B0c4324c1d8B3AD2A00; 
    feesCollector = 0x8D6051dEdbE3B08590674B0c4324c1d8B3AD2A00; 
    
    require(_tokenAddress != address(0), "Token address cannot be zero"); 
    fundsToken = IERC20(_tokenAddress); 
    
    canBuy = true; 
    canClaim = true; 
    canTrade = true; 

    maxvalorcitoToRaise = 100000000000 ether; 
    totalvalorcito = 0; 
    
    buyFee = 100; // Tarifa del 1% para las compras de NFTs (100/10000).
    tradeFee = 100; // Tarifa del 1% para las transferencias de NFTs (100/10000).
    
    maxBatchCount = 10; 

}


function buy( uint256 valorcito, uint256 amount) external nonReentrant {
    
    require(canBuy == true, "Compras no habilitadas"); // Verificación de permisos de la compra con "canBuy". Incluir un mensaje de falla.
        
    // Verificacón de la cantidad de NFTs a comprar sea mayor que 0 y menor o igual al máximo permitido (maxBatchCount). Incluir un mensaje de falla.
    require(maxBatchCount >= amount && amount > 0, "Cantidad de NFTs no valida");
    require(totalvalorcito + (valorcito*amount)  < maxvalorcitoToRaise, "Valor total excede el maximo permitido");
    totalvalorcito += valorcito*amount;
    for (uint256 i = 0; i < amount; i++) { // Bucle desde 0 hasta amount-1 para mintear la cantidad especificada de NFTs.
        _safeMint(_msgSender(), tokenIdTracker.current()); // Minteo de NFT y asignación al msg.sender.
        emit Buy(_msgSender(), tokenIdTracker.current(), valorcito); // Evento Buy con el comprador, el tokenId y el valor del NFT.
        valorcitos[tokenIdTracker.current()] = valorcito; // Asignar el valor del NFT al tokenId actual en el mapeo valorcitos.
        validvalorcitos[valorcito] = true; // Marcar el valor como válido en el mapeo validvalorcitos.
        tokenIdTracker.increment() ;     
    }

    // Transfencia de fondos desde el comprador (_msgSender()) al recolector de fondos (fundsCollector) por el valor total de los NFTs comprados. 
      if (!fundsToken.transferFrom( _msgSender() ,fundsCollector, valorcito * amount)) {
        revert("Cannot send funds tokens"); // Incluir un mensaje de falla.
    }
    //Transferencia de tarifas de compra desde el comprador (_msgSender()) al recolector de tarifas (feesCollector).
    if (!fundsToken.transferFrom( _msgSender(), feesCollector, valorcito * amount * buyFee / 10000)) {
            revert("Cannot send fees tokens"); // Incluir un mensaje de falla.
       }
    
    }//end buy 


    // Funcion de compra de NFT que esta en venta.
    function trade( uint256 tokenId ) external nonReentrant { // Parámetro: ID del token.
        require(canBuy == true, "Compras no habilitadas"); 
        require( _exists(tokenId),"el token no existe"); 
       address actualOwner = ownerOf(tokenId);
       require( _msgSender() != actualOwner, "El comprador ya es el propietario");  
        TokenSale storage tokenSale = tokensOnSale[tokenId]; 
        require(tokenSale.onSale, "Token not On Sale"); 

        if (!fundsToken.transferFrom( _msgSender() ,actualOwner, tokenSale.valorcito) ) {
        revert("Cannot send funds tokens"); 
        }
        //Transferencia de tarifas de compra desde el comprador (_msgSender()) al recolector de tarifas (feesCollector).
        if (!fundsToken.transferFrom( _msgSender(), feesCollector, tokenSale.valorcito * buyFee / 10000)) {
            revert("Cannot send fees tokens"); 
            }
        emit Trade( actualOwner, _msgSender() ,  tokenId, tokenSale.valorcito);   

        _safeTransfer( actualOwner, _msgSender() ,tokenId,""); 

        tokenSale.onSale = false       ; 
        removeFromArray(listTokensOnSale, tokenId); 

   }


    // Función para poner en venta un NFT.

    function putOnSale(uint256 tokenId, uint256 price) external{
        require(canTrade == true, "Trade No Permnitido");
        require( _exists(tokenId), "Token no existe"); 
        require(ownerOf(tokenId) == _msgSender(), "No es el propietario del token "); 
        TokenSale storage tokenSale = tokensOnSale[tokenId]; 
        tokenSale.onSale = true            ; 
        tokenSale.valorcito = price               ;              
        addToArray( listTokensOnSale, tokenId); 
        emit PutOnSale(tokenId, price); 
    }


    //  cambie la  Lista de IDs de tokens por un entero por que me daba mucho gasto de gas y no compilaba
    function claim( uint256 tokenId ) external nonReentrant {
        require(canClaim == true , "No esta habilitado el claim ");
        TokenSale storage tokenSale; // Variable tokenSale.
        require(_exists(tokenId), "Token no existe"); 
        require(ownerOf(tokenId) == _msgSender(), "No es el propietario del token"); 
        tokenSale = tokensOnSale[tokenId]; 
        tokenSale.onSale = false         ; 
        _burn(tokenId); 
        emit   Claim( _msgSender()  ,  tokenId);
        if (!fundsToken.transferFrom( fundsCollector,_msgSender(),  tokenSale.valorcito ) ){
           revert("no se pueden enviar tokens"); // Incluir un mensaje de falla.
         }

    }



    // Verificar duplicados en el array antes de agregar un nuevo valor.
    function addToArray(   uint256 [] storage  list, uint256 tokenId ) private { // Parámetro, array de enteros donde se añadirá el valor y valor que se añadirá al array.
        uint256 index = find(list, tokenId);
        if (index  ==   list.length ) { 
            list.push(tokenId); 
        } else { 
            revert("Token ya en venta"); 
        }
    }

    // Eliminar un valor del array.
    function removeFromArray( uint256 [] storage list , uint256 valorcito) private  { 
        uint256 index = find(list, valorcito);
        if (index == list.length) { 
                revert("Token no esta en venta"); 
        } else { 
            list[index] = list[list.length - 1]; 
            list.pop(); 
                }
    }
    // Buscar un valor en un array y retornar su índice o la longitud del array si no se encuentra.
    function find(uint256 [] storage list, uint256 valorcito) private view returns(uint)  { // Parámetros, array de enteros en el cual se buscará el valor y valor que se buscará en el array..
        for (uint256 i = 0; i < list.length; i++) { 
            if (list[i] == valorcito) { 
                return i; 
            }
        }
        return   list.length      ; 
    }


    // Utilización del token ERC20 para transacciones.
    function setFundsToken( address token) external onlyOwner {                                                       
        require( token != address(0)); 
        fundsToken = IERC20(token); 
    }

    // Dirección para colectar los fondos de las ventas de NFTs.
    function setFundsCollector(address _address ) external onlyOwner { 
        require( _address != address(0)); 
        fundsCollector = _address; 
    }

    // Dirección para colectar las tarifas de transacción.
    function setFeesCollector( address _address ) external onlyOwner { 
        require( _address != address(0)); 
        feesCollector = _address; 
    }

    // Porcentaje de beneficio a pagar en las reclamaciones.
    function setProfitToPay(uint32 _profitToPay ) external onlyOwner { 
        profitToPay = _profitToPay; 
    }

    // Función que Habilita o deshabilita la compra de NFTs.
    function setCanBuy( bool _canBuy ) external onlyOwner { 
        canBuy = _canBuy;  
    }

    // Función que Habilita o deshabilita la reclamación de NFTs.
    function setCanClaim(bool  _canClaim ) external onlyOwner { 
        canClaim = _canClaim; 
    }

    // Función que Habilita o deshabilita el intercambio de NFTs.
    function setCanTrade( bool _canTrade) external onlyOwner { 
        canTrade = _canTrade; 
    }

    // Valor máximo que se puede recaudar de venta de NFTs.
    function setMaxvalorcitoToRaise(uint256  _maxvalorcitoToRaise ) external onlyOwner { 
        maxvalorcitoToRaise = _maxvalorcitoToRaise; 
    }
    
    // Función para agregar un valor válido para NFTs.   
    function addValidvalorcitos(uint256 valorcito) external onlyOwner {
        validvalorcitos[valorcito] = true; 
    }

    // Función para establecer la cantidad máxima de NFTs por operación.
    function setMaxBatchCount( uint16 _maxBatchCount ) external onlyOwner { 
        maxBatchCount = _maxBatchCount; 
    }

    // Tarifa aplicada a las compras de NFTs.
    function setBuyFee(uint16 _buyFee) external onlyOwner { 
        buyFee = _buyFee; 
    }

    // Tarifa aplicada a las transacciones de NFTs.
    function setTradeFee(uint16 _tradeFee) external onlyOwner { 
        tradeFee = _tradeFee; 
    }



} // contract CCNFT
