
CONTRACT_ID="mcp"
CHANNEL_ID="hachannel"
ORDERER_ADDR="orderer.microgrid.org"
UNIT="Wh"

HOUSE1="House01"
HOUSE2="House02"
HOUSE3="House03"
HOUSE4="House04"
HOUSE5="House05"
HOUSE6="House06"

HOUSE1_ADDR=${HOUSE1,,}".microgrid.org" # House01 to lower case
HOUSE2_ADDR=${HOUSE2,,}".microgrid.org" # House02 to lower case
HOUSE3_ADDR=${HOUSE3,,}".microgrid.org" # House03 to lower case
HOUSE4_ADDR=${HOUSE4,,}".microgrid.org" # House04 to lower case
HOUSE5_ADDR=${HOUSE5,,}".microgrid.org" # House05 to lower case
HOUSE6_ADDR=${HOUSE6,,}".microgrid.org" # House06 to lower case

PEER1="peer0."$HOUSE1_ADDR
PEER2="peer0."$HOUSE2_ADDR
PEER3="peer0."$HOUSE3_ADDR
PEER4="peer0."$HOUSE4_ADDR
PEER5="peer0."$HOUSE5_ADDR
PEER6="peer0."$HOUSE6_ADDR

TLS_ROOT_CERT_FILES_HOUSE1="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE1_ADDR/peers/$PEER1/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE2="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE2_ADDR/peers/$PEER2/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE3="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE3_ADDR/peers/$PEER3/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE4="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE4_ADDR/peers/$PEER4/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE5="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE5_ADDR/peers/$PEER5/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE6="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE6_ADDR/peers/$PEER6/tls/ca.crt"

CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/$ORDERER_ADDR/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"House01_001\",\"2019-01-25 12:03\",\"10\"]}'"

# sleep 3

for i in {1..4}
do
  # DATE_TIME=$( date +"%Y-%m-%d %T" )

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="EV"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE1\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE1\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="BESS"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE2\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE2\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="HVAC"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE3\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE3\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="EV"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE4\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE4\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="BESS"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE5\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE5\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  PRICE=$(( ( RANDOM % 100 )  + 1 ))
  QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
  if ((QUANTITY < 0)); then
    AGENTTYPE="PV"
  else
    AGENTTYPE="HVAC"
  fi
  echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$HOUSE6\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$HOUSE6\",\"$AGENTTYPE\",\"$UNIT\"]}'"

  sleep 30
done

sleep 5

echo -e "\n getBidsForLastNSeconds\n------------------------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getBidsForLastNSeconds\",\"300\"]}'"

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"

sleep 360

PRICE=150
QUANTITY=400
AGENTID="1002003"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=100
QUANTITY=600
AGENTID="1004002"
AGENTTYPE="EV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=40
QUANTITY=500
AGENTID="1001002"
AGENTTYPE="HVAC"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=50
QUANTITY=-600
AGENTID="1002006"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=70
QUANTITY=-600
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=120
QUANTITY=-500
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

sleep 60

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"
# echo -e "Correct values\n\tMCP: 70\n\tBPP: 100"
echo -e 'Correct values: {"MCP": 70, "BPP": 100}'


sleep 360

PRICE=150
QUANTITY=400
AGENTID="1002003"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=100
QUANTITY=800
AGENTID="1004002"
AGENTTYPE="EV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=40
QUANTITY=300
AGENTID="1001002"
AGENTTYPE="HVAC"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=50
QUANTITY=-600
AGENTID="1002006"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=70
QUANTITY=-400
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=120
QUANTITY=-700
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

sleep 60

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"
# echo -e "Correct values\n\tMCP: 70\n\tBPP: 100"
echo -e 'Correct values: {"MCP": 50, "BPP": 150}'


sleep 360

PRICE=150
QUANTITY=400
AGENTID="1002003"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=100
QUANTITY=800
AGENTID="1004002"
AGENTTYPE="EV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=40
QUANTITY=300
AGENTID="1001002"
AGENTTYPE="HVAC"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=50
QUANTITY=-600
AGENTID="1002006"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=70
QUANTITY=-600
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=120
QUANTITY=-500
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

sleep 60

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"
# echo -e "Correct values\n\tMCP: 70\n\tBPP: 100"
echo -e 'Correct values: {"MCP": 70, "BPP": 100}'


sleep 360


PRICE=100
QUANTITY=400
AGENTID="1002003"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=50
QUANTITY=800
AGENTID="1004002"
AGENTTYPE="EV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=120
QUANTITY=-600
AGENTID="1002006"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=160
QUANTITY=-400
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

sleep 60

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"
# echo -e "Correct values\n\tMCP: 70\n\tBPP: 100"
echo -e 'Correct values: {"MCP": 70, "BPP": 100}'


sleep 360

PRICE=50
QUANTITY=-120
AGENTID="1002003"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=100
QUANTITY=600
AGENTID="1004002"
AGENTTYPE="EV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=150
QUANTITY=400
AGENTID="1001002"
AGENTTYPE="HVAC"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=100
QUANTITY=-1000
AGENTID="1002006"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

PRICE=40
QUANTITY=500
AGENTID="1003001"
AGENTTYPE="PV"
echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"
docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'"

sleep 60

echo -e "\n getMCP\n--------"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"
# echo -e "Correct values\n\tMCP: 50\n\tBPP: 100"
echo -e 'Correct values: {"MCP": 50, "BPP": 100}'
