package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"sort"
	"time"
	"strconv"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	// "github.com/hyperledger/fabric/common/util"
)

/*
 *
 */
type MarketClearingPrice struct {
}

type Bid struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	Price			int64 	`json:"price"` 			 // The price per unit energy that either a consumer is willing to pay, or a generator is willing to sell for.
	Quantity  int64		`json:"quantity"` 	 // The energy quantity tied to the bid. A positive value indicates that the bid represents consumption (demand curve) and a negative value indicates generation (supply curve).
	AgentID 	string 	`json:"agent_id"`	 // A unique ID for each agent. May be used in post-processing, not in the market evaluation.
	AgentType	string 	`json:"agent_type"` // The type of agent: "HVAC", "PV", "EV", "BESS", "Critical", "Grid"
	Unit 			string 	`json:"unit"` 			 // Can be used to define the bid quantity units. By default, the units are assumed to be in Wh.
	TimeStamp int64 	`json:"time_stamp"`  // Timestamp for when the bid was made, used to gather bids placed over a given time period.
}

type Bids struct {
	Supply []Bid //supply
	Demand []Bid //demand
}

type MCPResponse struct {
	MCP int64
	BPP int64
}

// ToChaincodeArgs converts string args to []byte args
// Taken from util.go
func ToChaincodeArgs(args ...string) [][]byte {
        bargs := make([][]byte, len(args))
        for i, arg := range args {
                bargs[i] = []byte(arg)
        }
        return bargs
}

/*
 * The Init method is called during chaincode instantiation to initialize any data.
 * Best practice is to have any Ledger initialization in separate function -- see initLedger()
 */
func (s *MarketClearingPrice) Init(stub shim.ChaincodeStubInterface) peer.Response {
	return shim.Success(nil)
}

/*
 * The Invoke method is called as a result of an application request to run the
 * chaincode.
 * The calling application program has also specified the particular
  * chaincode function to be called, with arguments
*/
func (s *MarketClearingPrice) Invoke(stub shim.ChaincodeStubInterface) peer.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := stub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "getMCP" {
		return s.getMCP(stub, args)
	} else if function == "putBid" {
		return s.putBid(stub, args)
	} else if function == "getBid" {
		return s.getBid(stub, args)
	} else if function == "getBidsForLastNSeconds" {
		return s.getBidsForLastNSeconds(stub, args)
	}
	return shim.Error("Invalid chaincode function name.")
}


// getMCP chaincode function - requires 1 argument: NSeconds
func (s *MarketClearingPrice) getMCP(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1.")
	}

	NSeconds, err := strconv.ParseInt(args[0], 10, 64)
	// NSeconds, err := strconv.Atoi(args[0])
	if err != nil {
		errStr := fmt.Sprintf("Failed to parse num seconds (args[0]) as int. Got error: %s", err.Error())
		return shim.Error(errStr)
	}

	ts, err := stub.GetTxTimestamp()
	if err != nil {
		errStr := fmt.Sprintf("Error getting transaction timestamp: %s", err.Error())
		return shim.Error(errStr)
	}

	time_start := strconv.FormatInt(ts.GetSeconds() - NSeconds, 10)

	queryStr := "{\"selector\":{\"time_stamp\": {\"$gt\":" + time_start + "} }}"
	// queryStr := fmt.Sprintf("{\"selector\":{\"docType\":\"bid\",\"time_stamp\":{\"$gt\":%d} }}", time_start)
	// debug; not printed to terminal
	// check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
	fmt.Printf("- getMCP:\n\tqueryStr:%s\n", queryStr)

	resultsIterator, err := stub.GetQueryResult(queryStr)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var bids_buffer bytes.Buffer
	var supply_buffer bytes.Buffer
	var demand_buffer bytes.Buffer
	supply_buffer.WriteString(`{"supply":[`)
	demand_buffer.WriteString(`"demand":[`)

	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		// queryResponse to Bid struct in order to check Bid.Price
		bid := Bid{}
		//umarshal the data to a new bid struct
		err = json.Unmarshal(queryResponse.Value, &bid)
		if err != nil {
			return shim.Error(err.Error())
		}

		/* Use bid to separate between demand and supply bids
		 * see page 2 in the "Intra-community Real-time Marketplace" document
		 * Once the bids are collected for a given market interval,
		 * they are split into Supply and Demand bids. This distinction is based on
		 * the sign (+/–) of the bid quantity. The sign convention is such that
		 * consumption (demand) is positive, and generation (supply) is negative.
		 */
		if bid.Quantity > 0 { // Demand quantity - positive
			demand_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			demand_buffer.WriteString(",")
		} else {  // supply quantity - negative
			supply_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			supply_buffer.WriteString(",")
		}
	}

	// get rid of the trailing ","
	supply_bytes := bytes.TrimRight(supply_buffer.Bytes(), ",")
	demand_bytes := bytes.TrimRight(demand_buffer.Bytes(), ",")

	bids_buffer.WriteString(string(supply_bytes))
	bids_buffer.WriteString(`],`)
	bids_buffer.WriteString(string(demand_bytes))
	bids_buffer.WriteString(`]}`)

	bids := Bids{}
	err = json.Unmarshal(bids_buffer.Bytes(), &bids)

	if err != nil {
		errStr := fmt.Sprintf("Failed to parse bidsAsBytes. Got error: %s", err.Error())
		fmt.Printf(errStr)
		return shim.Error(errStr)
	}

	// sort supply bids increasing
	sort.Slice(bids.Supply, func(i, j int) bool { return bids.Supply[i].Price < bids.Supply[j].Price })
	// sort demand bids decreasing
	sort.Slice(bids.Demand, func(i, j int) bool { return bids.Demand[i].Price > bids.Demand[j].Price })

	NSupplyBids := len(bids.Supply)
	NDemandBids := len(bids.Demand)
	NBids := NSupplyBids + NDemandBids

	/* Bid Table, e.g. Tabel 6 in the "Intra-community Real-time Marketplace" document
	 * 6 columns:
	 * [0] Unique x-values (quantity accumulated over supply and demand separately)
	 * [1] Demand bid price, unfilled (P_D)
	 * [2] Supply bid price, unfilled (P_S)
	 * [3] Demand bid price, filled (P_D,f)
	 * [4] Supply bid price, filled (P_S,f)
	 * [5] Difference in price (∆P = P_D,f – P_S,f)
	 */
	 // We cannot use an array since it's sizes needs to be known at compile time
	 // Instead we use a slice of slices, see:
	 // https://mikevella.info/post/2d-slices-and-arrays-in-golang/
	 bidTable := make([][]int64, NBids)
	 for i := range bidTable {
		 bidTable[i] = make([]int64, 6)
	 }

	// No NaN for integers, so we assign an int to the variable NaN
	// Since the prices are always > 0, we can chose any int < 1
	var NaN int64
	NaN = -23
	var X int64
	X = 0
	// Fill in supply values
	j := 0
	for i := 0; i < NSupplyBids; i++ {
		// Accumulate quantity
		bidTable[j][0] = X - bids.Supply[i].Quantity // supply quantities are negative
		bidTable[j][1] = NaN  // instead of a float NaN
		bidTable[j][2] = bids.Supply[i].Price
		bidTable[j][3] = NaN  // -1 instead of NaN
		bidTable[j][4] = bids.Supply[i].Price
		bidTable[j][5] = NaN // placeholder
		X = bidTable[j][0] // Accumulate quantity
		j++
	}
	// Fill in demand values
	X = 0
	for i := 0; i < NDemandBids; i++ {
		// Accumulate quantity
		bidTable[j][0] = X + bids.Demand[i].Quantity
		bidTable[j][1] = bids.Demand[i].Price
		bidTable[j][2] = NaN  // instead of NaN
		bidTable[j][3] = bids.Demand[i].Price
		bidTable[j][4] = NaN  // instead of NaN
		bidTable[j][5] = NaN // placeholder
		X = bidTable[j][0] // Accumulate quantity
		j++
	}

	// Sort bidTable in increasing X (column 0)
	sort.Slice(bidTable[:], func(i, j int) bool { return bidTable[i][0] < bidTable[j][0] })
	var row int
	// Fill in the filled prices (cols 3 and 4), and the price diff (col 5)
	for i := NBids - 2; i >= 0; i-- {  // begin w 2nd to last row and move to 1st
		if bidTable[i][3] == NaN {
			bidTable[i][3] = bidTable[i+1][3]
		}
		if bidTable[i][4] == NaN {
			bidTable[i][4] = bidTable[i+1][4]
		}

		if bidTable[i][3] == NaN || bidTable[i][4] == NaN {
			bidTable[i][5] = NaN
		} else {
			bidTable[i][5] = bidTable[i][3] - bidTable[i][4]
		}
		/* Find the critical row for MCP and BPP
		* The sign (+/–) of this column is more important than the value,
		* where a value of 0 should be represented by a positive sign.
		*/
		if bidTable[i][5] < 0 {
			row = i - 1
			}
	}

	fmt.Printf("- getMCP:\n\trow = %d\n", row)

	// Hack to fix merge redundant rows for Vertical Intersection
	for i := 1; i < NBids; i++ {
		if bidTable[i][0] == bidTable[i-1][0] {
			if bidTable[i-1][1] == NaN {
				bidTable[i-1][1] = bidTable[i][1]
			} else if bidTable[i][1] == NaN {
				bidTable[i][1] = bidTable[i-1][1]
			}
			if bidTable[i-1][2] == NaN {
				bidTable[i-1][2] = bidTable[i][2]
			} else if bidTable[i][2] == NaN {
				bidTable[i][2] = bidTable[i-1][2]
			}
			if bidTable[i-1][3] == NaN {
				bidTable[i-1][3] = bidTable[i][3]
			} else if bidTable[i][3] == NaN {
				bidTable[i][3] = bidTable[i-1][3]
			}
			if bidTable[i-1][4] == NaN {
				bidTable[i-1][4] = bidTable[i][4]
			} else if bidTable[i][1] == NaN {
				bidTable[i][4] = bidTable[i-1][4]
			}
		}
	}

	// Find MCP and BPP
	var mcp int64
	var bpp int64
	// No intersection
	if row < 0 {
		fmt.Printf("- getMCP:\n\tNo intersection\n")
		mcp = 0
		bpp = 0
	// Horizontal Supply Intersection
	} else if bidTable[row][2] == NaN {
		fmt.Printf("- getMCP:\n\tHorizontal Supply Intersection\n")
		mcp = bidTable[row][4]
		bpp = bidTable[row][3]
	// Horizontal Demand Intersection
	} else if bidTable[row][1] == NaN {
		fmt.Printf("- getMCP:\n\tHorizontal Demand Intersection\n")
		for i := row; i >= 0; i-- {
			if bidTable[i][1] != NaN {
				mcp = bidTable[i][4]
				bpp = bidTable[i][1]
				break
			}
		}
	// Vertical intersection
	} else if bidTable[row][1] != NaN && bidTable[row][2] != NaN {
		fmt.Printf("- getMCP:\n\tVertical intersection\n")
		mcp = bidTable[row][2]
		bpp = bidTable[row][1]
	}

	// debug; not printed to terminal
	// check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
	fmt.Printf("- getMCP:\n\tMCP:%d\n\tBPP:%d\n", mcp, bpp)

	// From:
	// https://stackoverflow.com/questions/47429035/how-to-return-transaction-id-time-stamp-on-execution-of-invoke-function-in-chai
	response, err := json.Marshal(MCPResponse{
		MCP: mcp,
		BPP: bpp,
	})

return shim.Success(response)

}

func (s *MarketClearingPrice) putBid(stub shim.ChaincodeStubInterface, args []string) peer.Response {
/*
		Price			int 		// The price per unit energy that either a consumer is willing to pay, or a generator is willing to sell for.
		Quantity  int 		// The energy quantity tied to the bid. A positive value indicates that the bid represents consumption (demand curve) and a negative value indicates generation (supply curve).
		AgentID 	string 	// A unique ID for each agent. May be used in post-processing, not in the market evaluation.
		AgentType	string 	// The type of agent: HVAC, PV, EV, BESS, Critical, Grid
		Unit 			string 	// Can be used to define the bid quantity units. By default, the units are assumed to be in Wh.
		TimeStamp string 	// Time stamp for when the bid was made, used to gather bids placed over a given time period.
*/
	if len(args) != 5 {
		return shim.Error(`Incorrect number of arguments. Expecting 5.
														0 -- Price			int\n
                            1 -- Quantity  	int\n
                            2 -- AgentID 		string\n
                            3 -- AgentType	string\n
														4 -- Unit 			string`)
	}

	// price, err := strconv.Atoi(args[0])
	price, err := strconv.ParseInt(args[0], 10, 64)
	if err != nil {
		errStr := fmt.Sprintf("Failed to parse bid (args[0]) as int. Got error: %s", err.Error())
		return shim.Error(errStr)
	}
	// quantity, err := strconv.Atoi(args[1])
	quantity, err := strconv.ParseInt(args[1], 10, 64)
	if err != nil {
		errStr := fmt.Sprintf("Failed to parse energy quantity (args[1]) as int. Got error: %s", err.Error())
		return shim.Error(errStr)
	}

	ts, err := stub.GetTxTimestamp()
	if err != nil {
		errStr := fmt.Sprintf("Error getting transaction timestamp: %s", err.Error())
		return shim.Error(errStr)
	}

	// golang's stupid-ass fucking time format
	ts_str := time.Unix(ts.GetSeconds(), 0).Format("060102_150405")
	// if err != nil {
	// 	errStr := fmt.Sprintf("Error converting stub.GetTxTimestamp() to string: %s", err.Error())
	// 	return shim.Error(errStr)
	// }

	// TxID/Key (transaction ID with format <AgentID>_<yMD_HMS> e.g. A23_190129_235723)
	key := args[2] + "_" + ts_str

	var bid = Bid{ObjectType: "Bid",
								Price: price,
								Quantity: quantity,
								AgentID: args[2],
								AgentType: args[3],
								Unit: args[4],
								TimeStamp: ts.GetSeconds()}

	bidAsBytes, _ := json.Marshal(bid)

	stub.PutState(key, bidAsBytes)

	// debug; not printed to terminal; check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
	fmt.Printf("- putBid:\n\tkey:%s\n", key)

	return shim.Success(nil)
}


func (s *MarketClearingPrice) getBid(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1.")
	}

	bidAsBytes, err := stub.GetState(args[0])
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(bidAsBytes)
}


func (s *MarketClearingPrice) getBidsForLastNSeconds(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1.")
	}

	NSeconds, err := strconv.ParseInt(args[0], 10, 64)
	// NSeconds, err := strconv.Atoi(args[0])
	if err != nil {
		errStr := fmt.Sprintf("Failed to parse num seconds (args[0]) as int. Got error: %s", err.Error())
		return shim.Error(errStr)
	}

	ts, err := stub.GetTxTimestamp()
	if err != nil {
		errStr := fmt.Sprintf("Error getting transaction timestamp: %s", err.Error())
		return shim.Error(errStr)
	}

	time_start := strconv.FormatInt(ts.GetSeconds() - NSeconds, 10)
	queryStr := "{\"selector\":{\"time_stamp\": {\"$gt\":" + time_start + "} }}"
	// queryStr := fmt.Sprintf("{\"selector\":{\"docType\":\"bid\",\"time_stamp\":{\"$gt\":%d} }}", time_start)
	// debug; not printed to terminal
	// check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
	fmt.Printf("- getBidsForLastNSeconds:\n\tqueryStr:%s\n", queryStr)

	resultsIterator, err := stub.GetQueryResult(queryStr)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var return_buffer bytes.Buffer
	var supply_buffer bytes.Buffer
	var demand_buffer bytes.Buffer
	supply_buffer.WriteString(`{"supply":[`)
	demand_buffer.WriteString(`"demand":[`)

	// debug; not printed to terminal
	// check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
	fmt.Printf("- getBidsForLastNSeconds:\n\tqueryResponse:")
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		// debug; not printed to terminal
		// check with "docker logs dev-peer0.house01.microgrid.org-mcp-1.0"
		fmt.Printf("\n%s", queryResponse)
		if err != nil {
			return shim.Error(err.Error())
		}

		// queryResponse to Bid struct in order to check Bid.Price
		bid := Bid{}
		//umarshal the data to a new bid struct
		err = json.Unmarshal(queryResponse.Value, &bid)
		if err != nil {
			return shim.Error(err.Error())
		}

		/* Use bid to separate between demand and supply bids
		 * see page 2 in the "Intra-community Real-time Marketplace" document
		 * Once the bids are collected for a given market interval,
		 * they are split into Supply and Demand bids. This distinction is based on
		 * the sign (+/–) of the bid quantity. The sign convention is such that
		 * consumption (demand) is positive, and generation (supply) is negative.
		 */
		if bid.Quantity > 0 { // Demand quantity - positive
			demand_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			demand_buffer.WriteString(",")
		} else {  // supply quantity - negative
			supply_buffer.WriteString(string(queryResponse.Value))
			// add a "," between records
			supply_buffer.WriteString(",")
		}
	}

	// get rid of the trailing ","
	supply_bytes := bytes.TrimRight(supply_buffer.Bytes(), ",")
	demand_bytes := bytes.TrimRight(demand_buffer.Bytes(), ",")

	return_buffer.WriteString(string(supply_bytes))
	return_buffer.WriteString(`],`)
	return_buffer.WriteString(string(demand_bytes))
	return_buffer.WriteString(`]}`)

	// debug; not printed to terminal; check with "docker logs <CONTAINER ID>"
	// docker logs dev-peer0.house01.microgrid.org-mcp-1.0
	fmt.Printf("\n- getBidsForLastNSeconds:\n\t%s\n", return_buffer.String())

	return shim.Success(return_buffer.Bytes())
}


// The main function is only relevant in unit test mode.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(MarketClearingPrice))
	if err != nil {
		fmt.Printf("Error creating new MarketClearingPrice: %s", err)
	}
}
