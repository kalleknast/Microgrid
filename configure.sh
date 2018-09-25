#!/bin/bash

DIR="./channel-artifacts"
CHANNEL_NAME=hachannel

../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config

if [ ! -d "$DIR" ]; then
    echo 'Making directory "channel-artifacts"'
    mkdir channel-artifacts
fi

../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

../bin/configtxgen -profile $CHANNEL_NAME -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID $CHANNEL_NAME -asOrg House01MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID $CHANNEL_NAME -asOrg House02MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID $CHANNEL_NAME -asOrg House03MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID $CHANNEL_NAME -asOrg House04MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID $CHANNEL_NAME -asOrg House05MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID $CHANNEL_NAME -asOrg House06MSP
