# TODO list

* [x] Set up basic network
    - Single computer
    - "solo" orderer
* [x] Write chaincode to record energy production and consumption
    - [ ] Make ```go build``` output something else than ```src```
    - [ ] fix the error when trying to run the chaincode
        - ```Error creating new Energy Record: error trying to connect to local peer: context deadline exceeded```
* [ ] Node.js application write energy data to the contract
* [ ] Write chaincode to bid and aggredate, Market Clearing Price (MCP) algorithm
* [ ] Implementing the violation marketplace
    - [ ] Tracking and settlement for participants in the violation marketplace
* [ ] Price optimization chaincode
* [ ] Modify the network to run on multiple machines
