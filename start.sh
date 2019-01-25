CHANNEL_ID="hachannel"
ORDERER_ADDR="orderer.microgrid.org"
CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem"

docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d

sleep 15s

echo "Creating channel $CHANNEL_ID"
docker exec -ti cli sh -c "peer channel create -o $ORDERER_ADDR:7050 -c $CHANNEL_ID -f ./channel-artifacts/channel.tx --tls --cafile $CA_FILE"

sleep 5s

echo "Adding peers to the channel"

for i in {1..6}
do
  HOUSE="House0"$i
  HOUSE_ADDR=${HOUSE,,}".microgrid.org"
  CORE_PEER_MSPCONFIGPATH="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/users/Admin@$HOUSE_ADDR/msp"
  CORE_PEER_LOCALMSPID=$HOUSE"MSP"
  for j in 0 1
  do
    PEER="peer"$j"."$HOUSE_ADDR
    CORE_PEER_TLS_ROOTCERT_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/peers/$PEER/tls/ca.crt"

    docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=$PEER:7051 CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel join -b $CHANNEL_ID.block"
    sleep .5s
  done
done

echo "Update anchor peers"

for i in {1..6}
do
  HOUSE="House0"$i
  HOUSE_ADDR=${HOUSE,,}".microgrid.org"
  PEER="peer0".$HOUSE_ADDR
  CORE_PEER_LOCALMSPID=$HOUSE"MSP"
  CORE_PEER_MSPCONFIGPATH="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/users/Admin@$HOUSE_ADDR/msp"
  CORE_PEER_TLS_ROOTCERT_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$HOUSE_ADDR/peers/$PEER/tls/ca.crt"
  CFG_TX_FILE="./channel-artifacts/"$HOUSE"Anchor.tx"

  docker exec -ti cli sh -c "CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH CORE_PEER_ADDRESS=$PEER:7051 CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE peer channel update -o $ORDERER_ADDR:7050 -c $CHANNEL_ID -f $CFG_TX_FILE --tls --cafile $CA_FILE"
  sleep 3s
done
