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

	response, err := APIstub.InvokeChaincode("getRecordsByRange", args, channelID)

	if err != nil {
		errStr := fmt.Sprintf("Failed to query getRecordsByRange. Got error: %s", err.Error())
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

// getRecord chaincode function - requires 1 argument, ex: args: ['RECORD23'],
func (s *EnergyRecords) getRecord(APIstub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	recordAsBytes, err := APIstub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}
	//---------------------------for testing purpose
	Record := Record{}

	//umarshal the data to a new record struct
	json.Unmarshal(recordAsBytes, &Record)
	fmt.Println(Record)

	//---------------------------
	return shim.Success(recordAsBytes)
}

func (s *EnergyRecords) appendRecord(APIstub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 4 {
		return shim.Error(`Incorrect number of arguments. Expecting 4.
														0 -- Key (transaction ID with format H<house #>_<yMD_HMS> e.g. H01_190129_235723)
                            1 -- House id\n
                            2 -- date and time\n
                            3 -- energy amount`)
	}
	//----------------------------------changed the indexing-------------------------
	var record = Record{House: args[1], Time: args[2], Amount: args[3]}

	recordAsBytes, _ := json.Marshal(record)
	APIstub.PutState(args[0], recordAsBytes)

	return shim.Success(nil)
}

// getAllRecords chaincode function - requires no arguments , ex: args: [''],
func (s *EnergyRecords) getAllRecords(APIstub shim.ChaincodeStubInterface) peer.Response {

	/*
	 * GetStateByRange returns a range iterator over a set of keys in the
	 * ledger. The iterator can be used to iterate over all keys
	 * between the startKey (inclusive) and endKey (exclusive).
	 * The keys are returned by the iterator in lexical order.
	 * Note that startKey and endKey can be empty string, which implies
	 * unbounded range query on start or end.
	 */
	startKey := ""
	endKey := ""

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getAllRecords:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

// The main function is only relevant in unit test mode.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(EnergyRecords))
	if err != nil {
		fmt.Printf("Error creating new Energy Record: %s", err)
	}
}
