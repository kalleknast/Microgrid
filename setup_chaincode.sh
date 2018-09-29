#!/bin/bash

echo "Installing chaincode"

CC_SRC_PATH=chaincode/go/src
docker exec -e "CORE_PEER_LOCALMSPID=House01MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" cli peer chaincode install -n carecords -v 1.0 -p "$CC_SRC_PATH" -l golang

echo "Instantiating chaincode"
