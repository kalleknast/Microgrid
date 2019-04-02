#!/bin/bash

ARTIFACT_DIR="./channel-artifacts"
CRYPTO_DIR="./crypto-config"
CHANNEL_NAME="hachannel"

#!/bin/bash
echo "Deleting old configs"
docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml down --volumes
docker rm -f $(docker ps -aq)
docker network prune
docker rmi -f $(docker images -q)

if [ ! -d "$ARTIFACT_DIR" ]; then
    echo 'Making directory "channel-artifacts"'
    mkdir channel-artifacts
else
    echo 'Removing contents of directory "channel-artifacts"'
    # remove all contents of $DIR
    rm -rf $ARTIFACT_DIR/*
fi

if [ -d "$CRYPTO_DIR" ]; then
    echo 'Removing contents of directory "crypto-config"'
    rm -rf $CRYPTO_DIR
fi

../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config

# replace private keys, see lines 287-315
# https://github.com/hyperledger/fabric-samples/blob/master/first-network/byfn.sh
# Copy the template to the file that will be modified to add the private key
cp base/docker-compose-base-template.yaml base/docker-compose-base.yaml
CURRENT_DIR=$PWD
cd crypto-config/peerOrganizations/house01.microgrid.org/ca
PRIV_KEY=$(ls *_sk)
cd "$CURRENT_DIR"
sed "-i" "s/CA1_PRIVATE_KEY/${PRIV_KEY}/g" base/docker-compose-base.yaml

../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

../bin/configtxgen -profile HAChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID $CHANNEL_NAME -asOrg House01MSP

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID $CHANNEL_NAME -asOrg House02MSP

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID $CHANNEL_NAME -asOrg House03MSP

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID $CHANNEL_NAME -asOrg House04MSP

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID $CHANNEL_NAME -asOrg House05MSP

../bin/configtxgen -profile HAChannel -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID $CHANNEL_NAME -asOrg House06MSP
