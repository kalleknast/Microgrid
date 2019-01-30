package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"sort"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"github.com/hyperledger/fabric/core/util"
)

/*
 *
 */
type MarketClearingPrice struct {
}

/*github.com/hyperledger/fabric/core/chaincode/shgithub.com/hyperledger/fabric/core/chaincode/shim
 * Define the structure for a single record, with 3 properties.
 * Structure tags are used by encoding/json library
 */
type Record struct {
	House  string `json:"house"`
	Time   string `json:"time"`
	Amount string `json:"amount"`
}

/*
 * The Init method is called during chaincode instantiation to initialize any data.
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *EnergyRecords) Init(APIstub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the
 * chaincode.
 * The calling application program has also specified the particular
  * chaincode function to be called, with arguments
*/
func (s *MCP) Invoke(APIstub shim.ChaincodeStubInterface) peer.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 2.")
	}

	Key0 := args[0]
	Key1 := args[1]
	channelID := args[2]
	// TODO Check that Key0 is <= Key1
	invokeArgs := util.ToChaincodeAgs(key0, key1)

	response, err := APIstub.InvokeChaincode("getBidsByRange", args, channelID)

	if err != nil {
		errStr := fmt.Sprintf("Failed to query getBidsByRange. Got error: %s", err.Error())
		fmt.Printf(errStr)
		return shim.Error(errStr)
	}

	recordAsBytes := response.GetPayload()

	Record := Record{}

	//umarshal the data to a new record struct
	json.Unmarshal(recordAsBytes, &Record)
	fmt.Println(Record)

	/* TODO
	 * 1) Turn the record into somekind of iterable
	 * 2) Split into 2 arrays: supply & demand bids
	 * 3) Get number of records (len(response)?)
	 * 4) Sort supply bids increasing and demand bids decreasing
	 * 5) find MCP...
	 * 6) name shit...
	*/
}

// The main function is only relevant in unit test mode.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(EnergyRecords))
	if err != nil {
		fmt.Printf("Error creating new Energy Record: %s", err)
	}
}
