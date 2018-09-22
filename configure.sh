#!/bin/bash

DIR="./channel-artifacts"

../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config

if [ ! -d "$DIR" ]; then
    echo 'Making directory "channel-artifacts"'
    mkdir channel-artifacts
fi

../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

../bin/configtxgen -profile MicroGridChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID MicroGridChannel

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID MicroGridChannel -asOrg House01MSP

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID MicroGridChannel -asOrg House02MSP

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID MicroGridChannel -asOrg House03MSP

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID MicroGridChannel -asOrg House04MSP

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID MicroGridChannel -asOrg House05MSP

../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID MicroGridChannel -asOrg House06MSP
