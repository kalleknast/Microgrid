#!/bin/bash
docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d

echo "Creating channel 'hachannel'"

docker exec -ti cli sh -c "peer channel create -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

