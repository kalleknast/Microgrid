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
```bash
$ vim ~/.bashrc
```
At the end of ```.bashrc``` add
```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
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
$ ../bin/configtxgen -profile MicroGridChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID MicroGridChannel
```
```channel.tx``` should be created in ```channel-artifacts``` and the last line printed should look something like this:
```
2018-08-24 14:38:49.079 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 010 Writing new channel tx
```

#### Anchor peer transactions:
```bash
$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House01Anchor.tx -channelID MicroGridChannel -asOrg House01MSP

$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House02Anchor.tx -channelID MicroGridChannel -asOrg House02MSP

$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House03Anchor.tx -channelID MicroGridChannel -asOrg House03MSP

$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House04Anchor.tx -channelID MicroGridChannel -asOrg House04MSP

$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House05Anchor.tx -channelID MicroGridChannel -asOrg House05MSP

$ ../bin/configtxgen -profile MicroGridChannel -outputAnchorPeersUpdate ./channel-artifacts/House06Anchor.tx -channelID MicroGridChannel -asOrg House06MSP
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

```
Error creating new Energy Record: error trying to connect to local peer: context deadline exceeded
```

```bash
LANGUAGE=${1:-"golang"}
CC_SRC_PATH=chaincode/go/src
# CC_SRC_PATH=/opt/gopath/src/chaincode/go/src
docker exec -e "CORE_PEER_LOCALMSPID=House01MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/house01.microgrid.org/users/Admin@house01.microgrid.org/msp" cli peer chaincode install -n CArecords -v 1.0 -p "$CC_SRC_PATH" -l "$LANGUAGE"

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n fabcar -l "$LANGUAGE" -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
```
