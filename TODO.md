# TODO list

* [x] Set up basic network
    - [x] Single computer
    - [x] "solo" orderer
* [x] Write chaincode to record energy production and consumption
    - [x] See that it compiles
    - [x] install
    - [x] instantiate in a channel
        - [x] Add channel
        - [x] peer join
    - [x] Make ```go build``` output something else than ```src```
    - [x] See if the chaincode container in docker-compose-cli.yaml is neccessary
          **Conclusion**: *it could be removed*
* [ ] Node.js application write energy data to the contract
    - [ ] figure out what to do with the admin secret key in ```enrollAdmin.js```
    - [ ] fix the ```affiliation``` setting, ```org1.department1``` seems to be hardcoded in ```/etc/hyperledger/fabric-ca-server/fabric-ca-server-config.yaml``` in the ```ca.microgrid.org``` container.
* [ ] Write chaincode to bid and aggregate, Market Clearing Price (MCP) algorithm
* [ ] Implementing the violation marketplace
    - [ ] Tracking and settlement for participants in the violation marketplace
* [ ] Price optimization chaincode
* [ ] Modify the network to run on multiple machines
