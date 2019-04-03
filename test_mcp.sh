
CONTRACT_ID="mcp"
CHANNEL_ID="hachannel"
ORDERER_ADDR="orderer.microgrid.org"
UNIT="Wh"
LOG_FILE="mcp_test.log"
CA_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/microgrid.org/orderers/$ORDERER_ADDR/msp/tlscacerts/tlsca.microgrid.org-cert.pem"
AGENTTYPES_SUPPLY=("PV" "PV" "PV" "PV" "PV" "PV")
AGENTTYPES_DEMAND=("EV" "BESS" "HVAC" "EV" "BESS" "HVAC")
AGENTS=("House01" "House02" "House03" "House04" "House05" "House06")

AGENT1=${AGENTS[0]}
AGENT1_ADDR=${AGENT1,,}".microgrid.org" # House01 to lower case
PEER1="peer0."${AGENT1,,}".microgrid.org"
TLS_ROOT_CERT_FILE_AGENT1="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$AGENT1_ADDR/peers/$PEER1/tls/ca.crt"

PEER2="peer0."${AGENTS[1],,}".microgrid.org"
AGENT2_ADDR=${AGENTS[1],,}".microgrid.org" # House02 to lower case
TLS_ROOT_CERT_FILE_AGENT2="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$AGENT2_ADDR/peers/$PEER2/tls/ca.crt"

echo "A log of the test will be written to $PWD/$LOG_FILE"

#-------------------------------------------------------------------------------
# Running random bids
#-------------------------------------------------------------------------------
DATE_TIME=$( date +"%Y-%m-%d %T" )
echo -e "    Putting random bids in putBid()\n========================================\n Time: $DATE_TIME" > $LOG_FILE
echo "Running random bids"

for i in {1..4}
do
  for ((j=0; j<${#AGENTS[@]}; j++))
  do
    AGENT=${AGENTS[j]}
    PEER="peer0."${AGENT,,}".microgrid.org"
    AGENT_ADDR=${AGENT,,}".microgrid.org" # to lower case
    TLS_ROOT_CERT_FILE_AGENT="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$AGENT_ADDR/peers/$PEER/tls/ca.crt"

    PRICE=$(( ( RANDOM % 100 )  + 1 ))
    QUANTITY=$(( ( RANDOM % 100 )  - 50 ))
    if ((QUANTITY < 0)); then
      AGENTTYPE="${AGENTTYPES_SUPPLY[$j]}"
    else
      AGENTTYPE="${AGENTTYPES_DEMAND[$j]}"
    fi
    echo -e "\nInvoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENT\n\tagent type:$AGENTTYPE\n\tunit:$UNIT"  >> $LOG_FILE
    docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILE_AGENT1 --peerAddresses $PEER:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILE_AGENT  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENT\",\"$AGENTTYPE\",\"$UNIT\"]}'"   >> $LOG_FILE
  done
  sleep 30
done
sleep 30
echo -e "\ngetBidsForLastNSeconds:" >> $LOG_FILE
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getBidsForLastNSeconds\",\"300\"]}'"  >> $LOG_FILE
echo -e "\ngetMCP:"  >> $LOG_FILE
docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"  >> $LOG_FILE


#-------------------------------------------------------------------------------
# Running tests from 'Intra-community Real-time Marketplace'
#-------------------------------------------------------------------------------
echo -e "\n\n Running tests from 'Intra-community Real-time Marketplace' (MCP Calculation Procedure.pdf)\n============================================================================================"  >> $LOG_FILE
echo "Runnng test cases from 'Intra-community Real-time Marketplace'"

# Function for running the tests
function run_test {
  sleep 300
  echo -e "\tTest $TEST"
  DATE_TIME=$( date +"%Y-%m-%d %T" )
  echo -e "\n Test $TEST\n-------------\nStart time $DATE_TIME" >> $LOG_FILE
  for ((i=0; i<${#PRICES[@]}; i++))
  do
    echo -e "\nInvoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:${PRICES[$i]}\n\tquantity:${QUANTITES[$i]}\n\taguent:${AGENTIDS[$i]}\n\tagent type:${AGENTTYPES[i]}\n\tunit:$UNIT" >> $LOG_FILE
    docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILE_AGENT1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILE_AGENT2  -c '{\"Args\":[\"putBid\",\"${PRICES[i]}\",\"${QUANTITES[i]}\",\"${AGENTIDS[i]}\",\"${AGENTTYPE[i]}\",\"$UNIT\"]}'" >> $LOG_FILE
    sleep 30
  done
  sleep 30
  DATE_TIME=$( date +"%Y-%m-%d %T" )
  echo -e "\ngetBidsForLastNSeconds ($DATE_TIME):" >> $LOG_FILE
  docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getBidsForLastNSeconds\",\"300\"]}'"  >> $LOG_FILE
  DATE_TIME=$( date +"%Y-%m-%d %T" )
  echo -e "\ngetMCP ($DATE_TIME):" >> $LOG_FILE
  docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'"  >> $LOG_FILE
  echo -e "Correct values:\n{\"MCP\": ${CORRECT[0]}, \"BPP\": ${CORRECT[1]}}\n" >> $LOG_FILE
}

TEST=1
PRICES=(150 100 40 50 70 120)
QUANTITES=(400 600 500 -600 -600 -500)
AGENTIDS=("1002003" "1004002" "1001002" "1002006" "1003001" "1003001")
AGENTTYPES=("PV" "PV" "PV" "PV" "PV" "PV")
CORRECT=(70 100)
run_test

TEST=2
PRICES=(150 100 40 50 70 120)
QUANTITES=(400 800 300 -600 -400 -700)
AGENTIDS=("1002003" "1004002" "1001002" "1002006" "1003001" "1003001")
AGENTTYPES=("PV" "PV" "PV" "PV" "PV" "PV")
CORRECT=(50 150)
run_test

TEST=3
PRICES=(150 100 40 50 70 120)
QUANTITES=(400 800 300 -600 -600 -500)
AGENTIDS=("1002003" "1004002" "1001002" "1002006" "1003001" "1003001")
AGENTTYPES=("PV" "PV" "PV" "PV" "PV" "PV")
CORRECT=(70 100)
run_test

TEST=4
PRICES=(100 50 120 160)
QUANTITES=(400 800 -600 -400)
AGENTIDS=("1002003" "1004002" "1002006" "1003001")
AGENTTYPES=("PV" "PV" "PV" "PV")
CORRECT=(0 0)
run_test


# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"appendRecord\",\"House01_001\",\"2019-01-25 12:03\",\"10\"]}'"

# sleep 360


# PRICE=50
# QUANTITY=-120
# AGENTID="1002003"
# AGENTTYPE="PV"
# echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'" >> $LOG_FILE
#
# PRICE=100
# QUANTITY=600
# AGENTID="1004002"
# AGENTTYPE="EV"
# echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'" >> $LOG_FILE
#
# PRICE=150
# QUANTITY=400
# AGENTID="1001002"
# AGENTTYPE="HVAC"
# echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'" >> $LOG_FILE
#
# PRICE=100
# QUANTITY=-1000
# AGENTID="1002006"
# AGENTTYPE="PV"
# echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'" >> $LOG_FILE
#
# PRICE=40
# QUANTITY=500
# AGENTID="1003001"
# AGENTTYPE="PV"
# echo -e "Invoking $CONTRACT_ID with arguments:\n func: putBid\n\tprice:$PRICE\n\tquantity:$QUANTITY\n\taguent:$AGENTID\n\tagent type:$AGENTTYPE\n\tunit:$UNIT" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode invoke -o $ORDERER_ADDR:7050 --tls true --cafile $CA_FILE -C $CHANNEL_ID -n $CONTRACT_ID --peerAddresses $PEER1:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE1 --peerAddresses $PEER2:7051 --tlsRootCertFiles $TLS_ROOT_CERT_FILES_HOUSE2  -c '{\"Args\":[\"putBid\",\"$PRICE\",\"$QUANTITY\",\"$AGENTID\",\"$AGENTTYPE\",\"$UNIT\"]}'" >> $LOG_FILE
#
# sleep 60
#
# echo -e "\n getMCP\n--------" >> $LOG_FILE
# docker exec -ti cli sh -c  "peer chaincode query -C $CHANNEL_ID -n $CONTRACT_ID -c '{\"Args\": [\"getMCP\",\"300\"]}'" >> $LOG_FILE
# # echo -e "Correct values\n\tMCP: 50\n\tBPP: 100"
# echo -e 'Correct values:\n{"MCP": 50, "BPP": 100}' >> $LOG_FILE
