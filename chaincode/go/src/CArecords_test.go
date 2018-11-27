package main

import (
	"strconv"
	"testing"

	"github.com/hyperledger/fabric/core/chaincode/shim"
)

/*
 */

func Test_CheckInit(t *testing.T) {
	scc := new(EnergyRecords)
	stub := shim.NewMockStub("records", scc)
	res := stub.MockInit("1", [][]byte{})
	if res.Status != shim.OK {
		t.Log("bad status received, expected: 200; received:" + strconv.FormatInt(int64(res.Status), 10))
		t.Log("response: " + string(res.Message))
		t.FailNow()
	}
}

func Test_Invoke_appendRecord(t *testing.T) {
	scc := new(EnergyRecords)
	stub := shim.NewMockStub("records", scc)
	res := stub.MockInvoke("1", [][]byte{[]byte("appendRecord"), []byte("001"), []byte("2018/9/3"), []byte("333")})
	if res.Status != shim.OK {
		t.Log("bad status received, expected: 200; received:" + strconv.FormatInt(int64(res.Status), 10))
		t.Log("response: " + string(res.Message))
		t.FailNow()
	}
	if res.Payload != nil {
		t.Log("appendRecord failed to append a record")
		t.FailNow()
	}

}

func Test_Invoke_getRecord(t *testing.T) {
	scc := new(EnergyRecords)
	stub := shim.NewMockStub("records", scc)
	res := stub.MockInvoke("1", [][]byte{[]byte("appendRecord"), []byte("001"), []byte("2018/9/3"), []byte("333")})
	res = stub.MockInvoke("2", [][]byte{[]byte("getRecord"), []byte("001")})

	if res.Status != shim.OK {
		t.Log("bad status received, expected: 200; received:" + strconv.FormatInt(int64(res.Status), 10))
		t.Log("response: " + string(res.Message))
		t.FailNow()
	}
	if res.Payload == nil {
		t.Log("initBallot failed to create a ballot")
		t.FailNow()
	}

}

func Test_Invoke_getAllRecords(t *testing.T) {
	scc := new(EnergyRecords)
	stub := shim.NewMockStub("records", scc)
	res := stub.MockInvoke("1", [][]byte{[]byte("appendRecord"), []byte("001"), []byte("2018/9/3"), []byte("5")})
	res = stub.MockInvoke("2", [][]byte{[]byte("appendRecord"), []byte("002"), []byte("2018/9/3"), []byte("33323")})
	res = stub.MockInvoke("3", [][]byte{[]byte("appendRecord"), []byte("003"), []byte("2018/9/4"), []byte("3353")})
	res = stub.MockInvoke("4", [][]byte{[]byte("appendRecord"), []byte("004"), []byte("2018/9/5"), []byte("3323")})
	res = stub.MockInvoke("5", [][]byte{[]byte("appendRecord"), []byte("005"), []byte("2018/9/6"), []byte("3343")})
	res = stub.MockInvoke("6", [][]byte{[]byte("appendRecord"), []byte("006"), []byte("2018/9/7"), []byte("444")})
	res = stub.MockInvoke("7", [][]byte{[]byte("getAllRecords")})

	if res.Status != shim.OK {
		t.Log("bad status received, expected: 200; received:" + strconv.FormatInt(int64(res.Status), 10))
		t.Log("response: " + string(res.Message))
		t.FailNow()
	}
	if res.Payload == nil {
		t.Log("initBallot failed to create a ballot")
		t.FailNow()
	}

}
