package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)
/*
 * EnergyRecords implements a chaincode to record the energy production/
 * consumption of HAs. One record per house and time point
 * Thus,
 * to record (set) 3 args are needed:
 *			Key ID
 * 				(transaction ID with format <yMD_HMS>_H<house #> e.g. 190129_235723_H01)
 *      House ID
 *		  Date Time
 * 				(format: %Y-%m-%d %T)
 *      energy amount (+/-)
 * 			Bid
 * to read (get) 2 args are needed:
 *      house ID
 *      date-time/incremental index
 */
type EnergyRecords struct {
}

/*github.com/hyperledger/fabric/core/chaincode/shgithub.com/hyperledger/fabric/core/chaincode/shimim
 * Define the structure for a single record, with 3 properties.
 * Structure tags are used by encoding/json library
 */
type Record struct {
	House  string `json:"house"`
	Time   string `json:"time"`
	Amount string `json:"amount"`
	Bid 	 string `json:"bid"`
}

/*
 * The Init method is called during chaincode instantiation to initialize any data.
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *EnergyRecords) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the
 * chaincode.
 * The calling application program has also specified the particular
  * chaincode function to be called, with arguments
*/
func (s *EnergyRecords) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := stub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "getRecord" {
		return s.getRecord(stub, args)
	} else if function == "appendRecord" {
		return s.appendRecord(stub, args)
	} else if function == "getBidsByRange" {
		return s.getBidsByRange(stub, args)
	} else if function == "getRecordsByRange" {
		return s.getRecordsByRange(stub, args)
	}

	return shim.Error("Invalid chaincode function name.")
}

// getRecord chaincode function - requires 1 argument, ex: args: ['190129_235723_H01'],
func (s *EnergyRecords) getRecord(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1.")
	}

	recordAsBytes, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(recordAsBytes)
}

/* Returns all records between the startKey (inclusive) and endKey (exclusive).
	 The records are split into supply and demand bids

   Examples

	 	Records between Key1 (inclusive) and Key2 (exclusive):
	 		[\"getBidsByRange\",\"$KEY1\",\"$KEY2\"]
		Records up until Key2 (exclusive):
	 		[\"getBidsByRange\",\"\",\"$KEY2\"]
		Records after Key1 (inclusive):
	 		[\"getBidsByRange\",\"$KEY1\",\"\"]
		All records:
	 		[\"getBidsByRange\",\"\",\"\"]
*/
func (s *EnergyRecords) getBidsByRange(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2.")
	}

	startKey := args[0]
	endKey := args[1]

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var return_buffer bytes.Buffer
	var supply_buffer bytes.Buffer
	var demand_buffer bytes.Buffer
	supply_buffer.WriteString(`{"supply":`)
	demand_buffer.WriteString(`{"demand":`)

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		// queryResponse to Record struct in order to check Record.Bid
		Record := Record{}
		//umarshal the data to a new record struct
		json.Unmarshal([]byte(queryResponse.Value), &Record)
		bid, err := strconv.Atoi(Record.Bid)
		if err != nil {
			return shim.Error(err.Error())
		}

		// Use bid to separate between demand and supply bids
		if bid < 0 { // Demand bid
			demand_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			supply_buffer.WriteString(",")
		} else {  // supply bid
			supply_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			demand_buffer.WriteString(",")
		}
	}

	// get rid of the trailing ","
	supply_bytes := bytes.TrimRight(supply_buffer.Bytes(), ",")
	demand_bytes := bytes.TrimRight(demand_buffer.Bytes(), ",")

	return_buffer.WriteString(string(supply_bytes))
	return_buffer.WriteString(`},`)
	return_buffer.WriteString(string(demand_bytes))
	return_buffer.WriteString(`}`)

	// debug; not printed to terminal; check with "docker logs <CONTAINER ID>"
	fmt.Printf("- getBidsByRange:\n%s\n", return_buffer.String())

	return shim.Success(return_buffer.Bytes())
}


func (s *EnergyRecords) appendRecord(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 5 {
		return shim.Error(`Incorrect number of arguments. Expecting 5.
														0 -- Key (transaction ID with format H<house #>_<yMD_HMS> e.g. H01_190129_235723)
                            1 -- House ID\n
                            2 -- date and time\n
                            3 -- energy amount\n
														4 -- Bid`)
	}
	//----------------------------------changed the indexing-------------------------
	var record = Record{House: args[1], Time: args[2], Amount: args[3], Bid: args[4]}

	recordAsBytes, _ := json.Marshal(record)
	stub.PutState(args[0], recordAsBytes)

	return shim.Success(nil)
}

/* getRecordsByRange chaincode function
   Either two args "Key_start" and  "Key_end",
   or NO args, in which case all records will be read.

	 Examples
	 
	 	Records between Key1 (inclusive) and Key2 (exclusive):
	 		[\"getBidsByRange\",\"$KEY1\",\"$KEY2\"]
		Records up until Key2 (exclusive):
	 		[\"getBidsByRange\",\"\",\"$KEY2\"]
		Records after Key1 (inclusive):
	 		[\"getBidsByRange\",\"$KEY1\",\"\"]
		All records:
	 		[\"getBidsByRange\",\"\",\"\"]
 */
func (s *EnergyRecords) getRecordsByRange(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	/*
	 * GetStateByRange returns a range iterator over a set of keys in the
	 * ledger. The iterator can be used to iterate over all keys
	 * between the startKey (inclusive) and endKey (exclusive).
	 * The keys are returned by the iterator in lexical order.
	 * Note that startKey and endKey can be empty string, which implies
	 * unbounded range query on start or end.
	 */
	 var startKey string
	 var endKey string

	 if len(args) == 2 {
		 startKey = args[0]
		 endKey = args[1]
 	} else if len(args) == 0 {
		startKey = ""
		endKey = ""
	} else {
		return shim.Error("Incorrect number of arguments. Expecting 2 or 0.")
	}

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
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

	// debug; not printed to terminal; check with "docker logs <CONTAINER ID>"
	fmt.Printf("- getRecordsByRange:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

// The main function is only relevant in unit test mode.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(EnergyRecords))
	if err != nil {
		// debug; not printed to terminal; check with "docker logs <CONTAINER ID>"
		fmt.Printf("Error creating new Energy Record: %s", err)
	}
}
