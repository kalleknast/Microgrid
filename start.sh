#!/bin/bash
docker-compose -f docker-compose-cli.yaml up -d

export CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=microgrid_net

echo "Creating channel 'hachannel'"

docker exec -ti cli sh -c "peer channel create -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

echo "Joining peer0.house01.microgrid.org to hachannel"

docker exec -ti cli sh -c 'CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house01.microgrid.org:7051 CORE_PEER_LOCALMSPID="House01MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/peers/peer0.house01.microgrid.org/tls/ca.crt peer channel join -b hachannel.block'
