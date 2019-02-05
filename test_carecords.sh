
CONTRACT_ID="carecords"
CHANNEL_ID="hachannel"
HOUSE1="House01"
HOUSE2="House02"
ORDERER_ADDR="orderer.microgrid.org"
HOUSE1_ADDR=${HOUSE1,,}".microgrid.org" # House01 to lower case
HOUSE2_ADDR=${HOUSE2,,}".microgrid.org" # House02 to lower case
PEER1="peer0."$HOUSE1_ADDR
PEER2="peer0."$HOUSE2_ADDR

TLS_ROOT_CERT_FILES_HOUSE1="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE1_ADDR/peers/$PEER1/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE2="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE2_ADDR/peers/$PEER2/tls/ca.crt"
CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/$ORDERER_ADDR/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"House01_001\",\"2019-01-25 12:03\",\"10\"]}'"

# sleep 3

for i in {1..4}
do
  DATE_TIME=$( date +"%Y-%m-%d %T" )
  KEY_DATETIME=$( date +"%y%m%d_%H%M%S" )
  # Key (transaction ID with format <yMD_HMS>_H<house #> e.g. 190129_235723_H01)
  KEY1=$KEY_DATETIME"_H"${HOUSE1:${HOUSE1}-2}
  KEY2=$KEY_DATETIME"_H"${HOUSE2:${HOUSE2}-2}

  echo "Invoking $CONTRACT_ID, Key: $KEY1"
  echo "Invoking $CONTRACT_ID, Key: $KEY2"
  SUP_BID=$(( ( RANDOM % 10 )  + 1 ))
  DEM_BID=$(( ( RANDOM % 10 )  - 10 ))
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"$KEY1\",\"House01\",\"$DATE_TIME\",\"10\",\"$SUP_BID\"]}'"
  docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"$KEY2\",\"House02\",\"$DATE_TIME\",\"10\",\"$DEM_BID\"]}'"
  # sleep 5
done

sleep 20
# docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getRecordsByRange\"]}'"

docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getRecordsByRange\",\"\",\"\"]}'"


# docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getBidsByRange\",\"190130_130421_H01\",\"190130_132451_H02\"]}'"
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getBidsByRange\",\"\",\"\"]}'"
