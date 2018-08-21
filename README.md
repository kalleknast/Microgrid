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
```$ vim ~/.bashrc```
At the end of ```.bashrc``` add
```
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

### Download Hyperledger fabric-samples to preffered directory
```
git clone -b master https://github.com/hyperledger/fabric-samples.git
```

### Install fabric binaries version 1.2 into the fabric-samples root directory
```
$ fabric-samples
$ curl -sSL http://bit.ly/2ysbOFE | bash -s 1.2.0
```

### Add the fabric binaries to ```PATH```
```$ vim ~/.bashrc```
At the end of ```.bashrc``` add
```
export PATH=<path to download location>/fabric-samples/bin:$PATH
```
