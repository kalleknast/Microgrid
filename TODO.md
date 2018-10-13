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
    - [ ] Make ```go build``` output something else than ```src```
    - [ ] See if the chaincode container in docker-compose-cli.yaml is neccessary
* [ ] Node.js application write energy data to the contract
* [ ] Write chaincode to bid and aggredate, Market Clearing Price (MCP) algorithm
* [ ] Implementing the violation marketplace
    - [ ] Tracking and settlement for participants in the violation marketplace
* [ ] Price optimization chaincode
* [ ] Modify the network to run on multiple machines
