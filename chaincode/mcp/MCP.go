package main

import (
	// "bytes"
	"encoding/json"
	"fmt"
	"sort"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
	"github.com/hyperledger/fabric/common/util"
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
// type Record struct {
// 	House  string `json:"house"`
// 	Time   string `json:"time"`
// 	Amount string `json:"amount"`
// }

type Bids struct {
	Supply []struct {
		Amount int `json:"amount"`
		Bid    int `json:"bid"`
		House  string `json:"house"`
		Time   string `json:"time"`
	} `json:"supply,omitempty"`
	Demand []struct {
		Amount int `json:"amount"`
		Bid    int `json:"bid"`
		House  string `json:"house"`
		Time   string `json:"time"`
	} `json:"demand,omitempty"`
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
	}
	return shim.Error("Invalid chaincode function name.")
}

// getMCP chaincode function - requires 3 arguments: key1, key2 and CHANNEL_ID
func (s *MarketClearingPrice) getMCP(stub shim.ChaincodeStubInterface, args []string) peer.Response {

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3.")
	}

	key0 := args[0]
	key1 := args[1]
	channelID := args[2]
	// TODO Check that Key0 is <= Key1
	invokeArgs := util.ToChaincodeArgs(key0, key1)

	response := stub.InvokeChaincode("getBidsByRange", invokeArgs, channelID)
	// if err != nil {
	// 	errStr := fmt.Sprintf("Failed to query getBidsByRange. Got error: %s", err.Error())
	// 	fmt.Printf(errStr)
	// 	return shim.Error(errStr)
	// }

	bidsAsBytes := response.GetPayload()

	bids := Bids{}
	// json.Unmarshal([]byte(recordAsBytes), &bids)
	err := json.Unmarshal(bidsAsBytes, &bids)

	if err != nil {
		errStr := fmt.Sprintf("Failed to parse bidsAsBytes. Got error: %s", err.Error())
		fmt.Printf(errStr)
		return shim.Error(errStr)
	}

	// sort supply bids increasing
	sort.Slice(bids.Supply, func(i, j int) bool { return bids.Supply[i].Bid < bids.Supply[j].Bid })
	// sort demand bids decreasing
	sort.Slice(bids.Demand, func(i, j int) bool { return bids.Demand[i].Bid > bids.Demand[j].Bid })

	mcp := 0
	accum_supply := 0

	for _, supply := range bids.Supply {

		accum_demand := 0
		accum_supply += supply.Amount

		for _, demand := range bids.Demand {

			accum_demand += demand.Amount

			if supply.Bid < -demand.Bid && accum_supply < accum_demand {
				mcp = supply.Bid
			}
		}
	}

return shim.Success(make([]byte, mcp))

}

// The main function is only relevant in unit test mode.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(MarketClearingPrice))
	if err != nil {
		fmt.Printf("Error creating new MarketClearingPrice: %s", err)
	}
}

/*

--------------------------------------------
FOR TESTING ON https://play.golang.org/
--------------------------------------------

package main

import (
	"encoding/json"
	"fmt"
	"sort"
)

func main() {


	bidsAsBytes := []byte(`{"supply":
					[{"amount":10,"bid":8,"house":"House01","time":"2019-02-05 11:06:39"},
					 {"amount":10,"bid":7,"house":"House01","time":"2019-02-05 11:06:55"},
					 {"amount":10,"bid":6,"house":"House01","time":"2019-02-05 11:06:56"},
					 {"amount":10,"bid":9,"house":"House01","time":"2019-02-05 11:14:51"},
					 {"amount":10,"bid":8,"house":"House01","time":"2019-02-05 11:14:52"},
					 {"amount":10,"bid":5,"house":"House01","time":"2019-02-05 11:14:53"}],
				"demand":
					[{"amount":10,"bid":-4,"house":"House02","time":"2019-02-05 11:06:39"},
					 {"amount":10,"bid":-7,"house":"House02","time":"2019-02-05 11:06:55"},
					 {"amount":10,"bid":-9,"house":"House02","time":"2019-02-05 11:06:56"},
					 {"amount":10,"bid":-4,"house":"House02","time":"2019-02-05 11:14:51"},
					 {"amount":10,"bid":-4,"house":"House02","time":"2019-02-05 11:14:52"},
					 {"amount":10,"bid":-4,"house":"House02","time":"2019-02-05 11:14:53"}]}`)

	type Bids struct {
		Supply []struct {
			Amount int `json:"amount"`
			Bid    int `json:"bid"`
			House  string `json:"house"`
			Time   string `json:"time"`
		} `json:"supply,omitempty"`
		Demand []struct {
			Amount int `json:"amount"`
			Bid    int `json:"bid"`
			House  string `json:"house"`
			Time   string `json:"time"`
		} `json:"demand,omitempty"`
	}

	bids := Bids{}

	err := json.Unmarshal(bidsAsBytes, &bids)

	if err != nil {
		errStr := fmt.Sprintf("Failed to parse bidsAsBytes. Got error: %s", err.Error())
		fmt.Printf(errStr)
	}

//	fmt.Println(bids.Supply)
//	fmt.Println(bids.Demand)



	// sort supply bids increasing
	sort.Slice(bids.Supply, func(i, j int) bool { return bids.Supply[i].Bid < bids.Supply[j].Bid })
	// sort demand bids decreasing
	sort.Slice(bids.Demand, func(i, j int) bool { return bids.Demand[i].Bid > bids.Demand[j].Bid })

	mcp := 0
	accum_supply := 0

	for _, supply := range bids.Supply {

		accum_demand := 0
		accum_supply += supply.Amount

		for _, demand := range bids.Demand {

			accum_demand += demand.Amount

			if supply.Bid < -demand.Bid && accum_supply < accum_demand {
				mcp = supply.Bid
			}
		}
	}

	fmt.Printf("%d\n", mcp)

}

*/
