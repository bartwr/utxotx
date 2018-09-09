#!/bin/bash

echo "This script will help you make a raw KMD transaction (tx)"

echo  

echo "First, launch: ~/Agama-linux-x64/resources/app/assets/bin/linux64/komodod --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo"

echo  

echo Whats the address you want to sign this tx with?

read tx_signer_address

echo Whats the address of the receiver?

read tx_receiver_address

echo Whats the amount of KMD you want to transact?

read tx_amount

echo What fee do you want to pay? in KMD

read tx_fee

tx_change=$tx_amount-$tx_fee

echo Now the more technical questions..

~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo validateaddress $tx_signer_address

echo What is your scriptPubKey?

read scriptPubKey

#echo If this is a multisig address, what is your hex? 
#
#read multisig_address_hex

echo Whats the tx id of the transaction you are going to select the vout from?

read tx_id

rawtransaction_hex=$(~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo getrawtransaction $tx_id)

echo THIS IS RAW TX:
echo $rawtransaction_hex
echo ----

tx_info_object="$(~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo decoderawtransaction $rawtransaction_hex)"

echo $tx_info_object > ~/utxotx_versions.txt
cat versions.txt

echo What vout do you want to use? -- "n": 1, means the 'vout' of the utxo is 1

read vout

~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo createrawtransaction '[{"txid":$tx_id,"vout":$vout,"scriptPubKey":$scriptPubKey}]' '{$tx_receiver_address:$tx_amount,"changeAddress":$tx_change}'

read created_rawtransaction_hex

echo ----------

echo tx_id to send from: $tx_id
echo signer address: $tx_signer_address
echo receiver address: $tx_receiver_address
echo amount to send: $tx_amount
echo fee: $tx_fee
echo ...
echo Is this correct?

echo ----------

echo Your private key for execution of this tx:

read privkey

signed_transaction_hex=$(~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo signrawtransaction '$created_rawtransaction_hex' '[{"txid":$tx_id,"vout":$vout,"scriptPubKey":$scriptPubKey}]' '["$privkey"]')

echo The output could include 'complete: true'. If this is the case, the tx was executed fully.

echo If it sais 'complete: false', it could be that an other MS wallet owner has to sign the tx to execute.

echo txid:

~/Agama-linux-x64/resources/app/assets/bin/linux64/komodo-cli --datadir=/media/bartwr/1d40b434-2974-4773-b90a-638a8dd931bd/.komodo sendrawtransaction $signed_transaction_hex
