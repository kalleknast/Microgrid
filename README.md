# Microgrid
Hyperledger network for microgrids


## Basic system setup

Assumes Ubuntu and follows instructions from https://hyperledger-fabric.readthedocs.io/en/release-1.2/

### Check docker version
```bash
$ docker --version
```
Docker compose version greater than 1.14.0 is required
```bash
$ docker-compose --version
```

### Go version 1.10.x is required
Check
```bash
$ go version
```

### Add go location to ```GOPATH``` and ```GOPATH``` to ```PATH```
Add path to ```.profile```
```bash
echo 'export GOPATH=/usr/local/go' >> ~/.profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile
```

### Download Hyperledger fabric-samples to preffered directory
```bash
$ git clone -b master https://github.com/hyperledger/fabric-samples.git
```

### Install fabric binaries version 1.2 into the fabric-samples root directory
```bash
$ fabric-samples
$ curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0
```

### Add the fabric binaries to ```PATH```
```bash
$ vim ~/.bashrc
```
At the end of ```.bashrc``` add
```bash
export PATH=<path to download location>/fabric-samples/bin:$PATH
```

## Set up the network

```bash
$ ../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config
```

These lines should be printed:
```bash
house01.microgrid.org
house02.microgrid.org
house03.microgrid.org
house04.microgrid.org
house05.microgrid.org
house06.microgrid.org
```

and a directory called ```crypto-config``` should created.

### Create the orderer genesis block, channel configuration transaction and the anchor peer transactions, one for each peer organisation

The ```configtxgen``` command doesn't automatically create the ```channel-artifacts``` directory.
Do it manually.
```bash
$ mkdir channel-artifacts
```

#### Genesis block:
```bash
$ ../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block
```

The last line printed should look something like:
```bash
2018-08-21 17:26:31.191 EDT [common/tools/configtxgen] doOutputBlock -> INFO 013 Writing genesis block
```

#### Channel configuration transaction:
```bash
$ ../bin/configtxgen -profile hachannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID hachannel
```
```channel.tx``` should be created in ```channel-artifacts``` and the last line printed should look something like this:
```
2018-08-24 14:38:49.079 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 010 Writing new channel tx
```

#### Anchor peer transactions:
```bash
$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID hachannel -asOrg House01MSP

$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID hachannel -asOrg House02MSP

$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID hachannel -asOrg House03MSP

$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID hachannel -asOrg House04MSP

$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID hachannel -asOrg House05MSP

$ ../bin/configtxgen -profile hachannel -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID hachannel -asOrg House06MSP
```

```House01Anchor.tx```, ```House02Anchor.tx``` ... should be located in ```channel-artifacts```
and the last lines printed should look something like this:
```
2018-08-24 14:46:37.491 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
2018-08-24 14:46:37.499 EDT [common/tools/configtxgen] doOutputAnchorPeersUpdate -> INFO 002 Generating anchor peer update
2018-08-24 14:46:37.499 EDT [common/tools/configtxgen] doOutputAnchorPeersUpdate -> INFO 003 Writing anchor peer update
```
### Peer-base and docker-compose

```bash
$ docker-compose -f docker-compose-cli.yaml up -d
```

The last few lines printed should look something like this:
```bash
dde25187799d: Pull complete
Digest: sha256:24cca44a2f2ab6325c6ccc1c91a10bd3e0e71764037a85a473f7e9621b3a0f91
Status: Downloaded newer image for hyperledger/fabric-tools:latest
Creating peer1.house03.microgrid.org ... done
Creating peer0.house01.microgrid.org ... done
Creating peer1.house02.microgrid.org ... done
Creating peer0.house02.microgrid.org ... done
Creating peer1.house06.microgrid.org ... done
Creating peer1.house01.microgrid.org ... done
Creating peer1.house04.microgrid.org ... done
Creating peer0.house04.microgrid.org ... done
Creating peer0.house05.microgrid.org ... done
Creating peer0.house06.microgrid.org ... done
Creating orderer.microgrid.org       ... done
Creating peer0.house03.microgrid.org ... done
Creating peer1.house05.microgrid.org ... done
Creating cli                         ... done
Creating chaincode                   ... done
```
Start docker cli:
```bash
$ docker start cli
```
Enter the ```cli``` docker container:
```bash
$ docker exec -it cli bash
```
Should look something like this:

```
root@b411f1d6d95e:/opt/gopath/src/github.com/hyperledger/fabric/peer#
```

To remove docker images:
```bash
$ docker rm -f $(docker ps -aq)
$ docker rmi -f $(docker images -q)
```

## chaincode

Assumes you are in ```microgrid```
```bash
$ cd chaincode/go/src
```
Test compile the chaincode outside of a container
```
$ go get -u github.com/hyperledger/fabric/core/chaincode/shim
$ go build
```

Install the chaincode
```bash
CC_SRC_PATH=chaincode/go/src
docker exec -e "CORE_PEER_LOCALMSPID=House01MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" cli peer chaincode install -n carecords -v 1.0 -p "$CC_SRC_PATH" -l golang
```

The last lines printed should be something like this:
```bash
2018-09-05 20:48:05.131 UTC [container] WriteFileToPackage -> DEBU 04e Writing file to tarball: src/chaincode/go/src/carecords.go
2018-09-05 20:48:05.135 UTC [msp/identity] Sign -> DEBU 04f Sign: plaintext: 0ACA070A5B08031A0B088582C1DC0510...F7C67F020000FFFF6A084374001A0000
2018-09-05 20:48:05.135 UTC [msp/identity] Sign -> DEBU 050 Sign: digest: 88E3BE1783D75457E36882431DCA4EDC77A7996F0C0BD3524E8DB208387A9B0B
2018-09-05 20:48:05.137 UTC [chaincodeCmd] install -> INFO 051 Installed remotely response:<status:200 payload:"OK" >
```

### Create the channel

First enter the cli:
```
docker exec -it cli bash # Enter the cli
```
and then create the channel:
```bash
export CHANNEL_NAME=hachannel
peer channel create -o orderer.microgrid.org:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/orderer.microgrid.org/msp/tlscacerts/tlsca.microgrid.org-cert.pem
```
Alternatively, without entering the cli
```bash
??
```

### Join peer to the channel

Join peer0.house01.microgrid.org to the channel
```bash
docker exec -e "CORE_PEER_LOCALMSPID=House01MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" peer0.house01.microgrid.org peer channel join -b hachannel.block
```
ERROR!
```bash
2018-09-25 22:32:58.573 UTC [main] InitCmd -> ERRO 001 Cannot run peer because cannot init crypto, folder "/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" does not exist
```
However, if I enter cli, I can cd to the folder, i.e.:
```bash
# works fine:
cd /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp
```

instantiate the chaincode in the channel (hachannel)
```bash
docker exec -e "CORE_PEER_LOCALMSPID=House01MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" cli peer chaincode instantiate -o orderer.microgrid.org:7050 -C hachannel -n carecords
 -l golang -v 1.0 -c '{"Args":[""]}' -P "OR ('House01MSP.member','House02MSP.member')"
```

<!--
Enter the ```chaincode``` docker container:
```bash
$ docker exec -it chaincode bash
```

Should looks something like this:
```
root@00c1cc5304ca:/opt/gopath/src/chaincode#
```
The location ```/opt/gopath/src/chaincode``` is set in ```docker-compose-cli.yaml```

Change directory and check that the source chaincode is there:
```
# cd go/src
# ls
```
You should see at least
```
CArecords.go
```
Compile the chaincode:
```
# go build
```
And run the chaincode:
```
# CORE_PEER_ADDRESS=peer0.house01.microgrid.org:7051 CORE_CHAINCODE_ID_NAME=cacc:0 ./src
```

- ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/genesis.block
- ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/genesis.block -->
