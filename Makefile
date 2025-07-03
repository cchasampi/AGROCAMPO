CONTRACT_ADDRESS:=0xCecA2E1bCa3B27d8435f99f61ceA52e51A8Ee6cB
PRUEBA := 0xcE23256ae677765a41E8D7E4d099359771615ca4
PRIVATE_KEY:=f90a94398d9ff02454c3240f0a556f0105c1a028bc464307fc0866efdcd209a0

PRICAR :=6e8338ede9e5d9f4c7148cd4cc15911d96506e8aefe8c1236aefabe03d25d90d

RPC_URL:="https://eth-sepolia.g.alchemy.com/v2/0dJefmtYwHYggpu_vnZs8DzYiyKI-ZsS"
RPC-URL_CAR:="https://eth-sepolia.g.alchemy.com/v2/kOHtloCasVASTvWIE_C4l"
NETWORK_ARGS := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

ETHERSCAN_API_KEY:=NJBAA29AQW2BJS5P7TSRACDD5VXWBSGRWF

NETWORK_ARGS_VERIFY := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify -vvvv --etherscan-api-key $(ETHERSCAN_API_KEY)	

NETWORK_ARGS_VERIFY_CAR := --rpc-url $(RPC_URL) --private-key $(PRICAR) --broadcast --verify -vvvv --etherscan-api-key $(ETHERSCAN_API_KEY)	

NETWORK := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast	

NET := --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) 

NETCAR := --rpc-url $(RPC_URL) --private-key $(PRICAR) --broadcast	

deployAndVerifyCCNFT:
	@forge script script/DEPLOY.s.sol:DEPLOYCCNFT $(NETWORK_ARGS_VERIFY) 

deployAndVerifyCCNFTCAR:
	@forge script script/DEPLOY.s.sol:DEPLOYCCNFTCAR $(NETWORK_ARGS_VERIFY)
deployBUSD:
	@forge script script/DeployBUSD.s.sol:DeployBUSD $(NETWORK_ARGS_VERIFY) 


buyNft:
	@forge script script/Interactions.s.sol:BUYNFT $(NETWORK) 

buyotroNft:
	@forge script script/Interactions.s.sol:BUYNFT $(NETCAR) 


putNft:
	@forge script script/Interactions.s.sol:PUTNFT $(NETWORK) 

putOtroNft:
	@forge script script/Interactions.s.sol:PUTNFT $(NETCAR) 

tradeNft:
	@forge script script/Interactions.s.sol:TRADENFT $(NETWORK) 


tradeOtroNft:
	@forge script script/Interactions.s.sol:TRADENFT $(NETCAR) 

claimNft:
	@forge script script/Interactions.s.sol:CLAIMNFT $(NETWORK) 


claimOtroNft:
	@forge script script/Interactions.s.sol:CLAIMNFT $(NETCAR) 



buyCar:
	@forge script script/Interactions.s.sol:BUYNFT $(NETCAR) 



buyCast:
	@cast send $(CONTRACT_ADDRESS) "buy(uint256 , uint256)" 1000 4 $(NET)

buyPrueba:
	@cast send ${CONTRACT_ADDRESS} "buy(uint256 , uint256)" 1000 4 --rpc-url ${RPC-URL_CAR} --private-key ${PRICAR}
