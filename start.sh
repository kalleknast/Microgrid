
CHANNEL_NAME=hachannel
docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d

sleep 15s

echo "Creating channel $CHANNEL_NAME"
docker exec -ti cli sh -c "peer channel create -o orderer.microgrid.org:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

sleep 5s

echo "Adding peers to the channel"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/peers/peer0.house01.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house01.microgrid.org:7051 CORE_PEER_LOCALMSPID="House01MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/peers/peer1.house01.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house01.microgrid.org:7051 CORE_PEER_LOCALMSPID="House01MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house02.microgrid.org/users/Admin@house02.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house02.microgrid.org/peers/peer0.house02.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house02.microgrid.org:7051 CORE_PEER_LOCALMSPID="House02MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house02.microgrid.org/peers/peer1.house02.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house02.microgrid.org:7051 CORE_PEER_LOCALMSPID="House02MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house03.microgrid.org/users/Admin@house03.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house03.microgrid.org/peers/peer0.house03.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house03.microgrid.org:7051 CORE_PEER_LOCALMSPID="House03MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house03.microgrid.org/peers/peer1.house03.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house03.microgrid.org:7051 CORE_PEER_LOCALMSPID="House03MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house04.microgrid.org/users/Admin@house04.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house04.microgrid.org/peers/peer0.house04.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house04.microgrid.org:7051 CORE_PEER_LOCALMSPID="House04MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house04.microgrid.org/peers/peer1.house04.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house04.microgrid.org:7051 CORE_PEER_LOCALMSPID="House04MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house05.microgrid.org/users/Admin@house05.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house05.microgrid.org/peers/peer0.house05.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house05.microgrid.org:7051 CORE_PEER_LOCALMSPID="House05MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house05.microgrid.org/peers/peer1.house05.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house05.microgrid.org:7051 CORE_PEER_LOCALMSPID="House05MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house06.microgrid.org/users/Admin@house06.microgrid.org/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house06.microgrid.org/peers/peer0.house06.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer0.house06.microgrid.org:7051 CORE_PEER_LOCALMSPID="House06MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house06.microgrid.org/peers/peer1.house06.microgrid.org/tls/ca.crt
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=peer1.house06.microgrid.org:7051 CORE_PEER_LOCALMSPID="House06MSP" CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_NAME.block"
sleep .5s

echo "Update anchor peers"
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house01.microgrid.org:7051 CORE_PEER_LOCALMSPID="House01MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/peers/peer0.house01.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House01Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
sleep 3s
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house02.microgrid.org/users/Admin@house02.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house02.microgrid.org:7051 CORE_PEER_LOCALMSPID="House02MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house02.microgrid.org/peers/peer0.house02.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House02Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
sleep 3s
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house03.microgrid.org/users/Admin@house03.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house03.microgrid.org:7051 CORE_PEER_LOCALMSPID="House03MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house03.microgrid.org/peers/peer0.house03.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House03Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
sleep 3s
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house04.microgrid.org/users/Admin@house04.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house04.microgrid.org:7051 CORE_PEER_LOCALMSPID="House04MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house04.microgrid.org/peers/peer0.house04.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House04Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
sleep 3s
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house05.microgrid.org/users/Admin@house05.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house05.microgrid.org:7051 CORE_PEER_LOCALMSPID="House05MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house05.microgrid.org/peers/peer0.house05.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House05Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
sleep 3s
docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house06.microgrid.org/users/Admin@house06.microgrid.org/msp CORE_PEER_ADDRESS=peer0.house06.microgrid.org:7051 CORE_PEER_LOCALMSPID="House06MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house06.microgrid.org/peers/peer0.house06.microgrid.org/tls/ca.crt peer channel update -o orderer.microgrid.org:7050 -c hachannel -f ./channel-artifacts/House06Anchor.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
