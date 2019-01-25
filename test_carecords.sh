
CONTRACT_ID="carecords"
CHANNEL_ID="hachannel"
HOUSE1="House01"
HOUSE2="House02"
ORDERER_ADDR="orderer.microgrid.org"
HOUSE1_ADDR=${HOUSE1,,}".microgrid.org"
HOUSE2_ADDR=${HOUSE2,,}".microgrid.org"
PEER1="peer0."$HOUSE1_ADDR
PEER2="peer0."$HOUSE2_ADDR

TLS_ROOT_CERT_FILES_HOUSE1="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE1_ADDR/peers/$PEER1/tls/ca.crt"
TLS_ROOT_CERT_FILES_HOUSE2="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE2_ADDR/peers/$PEER2/tls/ca.crt"
CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/$ORDERER_ADDR/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"House01\",\"2019-01-25 12:03\",\"10\"]}'"

sleep 3

docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getAllRecords\"]}'"
