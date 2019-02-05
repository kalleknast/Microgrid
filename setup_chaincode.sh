#!/bin/bash

CONTRACT1_ID="carecords"
CONTRACT2_ID="mcp"
CHANNEL_ID="hachannel"
ORDERER_ADDR="orderer.microgrid.org"
CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/$ORDERER_ADDR/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

echo "Installing chaincode"

for i in {1..6}
do
  HOUSE="House0"$i
  HOUSE_ADDR=${HOUSE,,}".microgrid.org"
  PEER_ADDR="peer0".$HOUSE_ADDR
  CORE_PEER_LOCALMSPID=$HOUSE"MSP"
  CORE_PEER_MSPCONFIGPATH="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/users/Admin@$HOUSE_ADDR/msp"
  CORE_PEER_TLS_ROOTCERT_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/peers/$PEER_ADDR/tls/ca.crt"

  docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=$PEER_ADDR:7051 CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n $CONTRACT1_ID -v 1.0 -p chaincode/$CONTRACT1_ID -l golang"
  sleep 3s
  docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=$PEER_ADDR:7051 CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer chaincode install -n $CONTRACT2_ID -v 1.0 -p chaincode/$CONTRACT2_ID -l golang"
  sleep 3s
done


HOUSE1="House01"
HOUSE2="House02"
HOUSE1_MSP=$HOUSE1"MSP"
HOUSE2_MSP=$HOUSE2"MSP"

echo "Instantiating chaincode"
docker exec -ti cli sh -c "peer chaincode instantiate -o $ORDERER_ADDR:7050 --tls --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT1_ID -v 1.0 -c '{\"Args\":[\"init\"]}' -P \"OR ('$HOUSE1_MSP.member', '$HOUSE2_MSP.member')\""
sleep 3s
docker exec -ti cli sh -c "peer chaincode instantiate -o $ORDERER_ADDR:7050 --tls --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT2_ID -v 1.0 -c '{\"Args\":[\"init\"]}' -P \"OR ('$HOUSE1_MSP.member', '$HOUSE2_MSP.member')\""
# docker exec -ti cli sh -c "peer chaincode instantiate -o $ORDERER_ADDR:7050 --tls --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT1_ID -v 1.0 -c '{\"Args\":[\"init\"]}' -P \"OR ('House01.member', 'House02.member')\""
