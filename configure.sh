#!/bin/bash

ARTIFACT_DIR="./channel-artifacts"
CRYPTO_DIR="./crypto-config"
CHANNEL_NAME=hachannel

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
    rm -rf $CRYPTO_DIR/*
fi

../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config

../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

../bin/configtxgen -profile $CHANNEL_NAME -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID $CHANNEL_NAME -asOrg House01MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID $CHANNEL_NAME -asOrg House02MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID $CHANNEL_NAME -asOrg House03MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID $CHANNEL_NAME -asOrg House04MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID $CHANNEL_NAME -asOrg House05MSP

../bin/configtxgen -profile $CHANNEL_NAME -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID $CHANNEL_NAME -asOrg House06MSP
