# Microgrid
Hyperledger network for microgrids


## Basic system setup

Assumes Ubuntu and follows instructions from https://hyperledger-fabric.readthedocs.io/en/release-1.2/

### Check docker version
```
$ docker --version
```
Docker compose version greater than 1.14.0 is required
```
$ docker-compose --version
```

### Go version 1.10.x is required
Check
```
$ go version
```

### Add go location to ```GOPATH``` and ```GOPATH``` to ```PATH```
```
$ vim ~/.bashrc
```
At the end of ```.bashrc``` add
```
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

### Download Hyperledger fabric-samples to preffered directory
```
$ git clone -b master https://github.com/hyperledger/fabric-samples.git
```

### Install fabric binaries version 1.2 into the fabric-samples root directory
```
$ fabric-samples
$ curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0
```

### Add the fabric binaries to ```PATH```
```
$ vim ~/.bashrc
```
At the end of ```.bashrc``` add
```
export PATH=<path to download location>/fabric-samples/bin:$PATH
```

## Set up the network

```
$ ../bin/cryptogen generate --config crypto-config.yaml --output=crypto-config
```

These lines should be printed:
```
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
```
$ mkdir channel-artifacts
```

```
$ ../bin/configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block
```

The last line printed should be something like:
```
2018-08-21 17:26:31.191 EDT [common/tools/configtxgen] doOutputBlock -> INFO 013 Writing genesis block
```
