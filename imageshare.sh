#!/bin/bash

AUTHURL=https://identity.api.rackspacecloud.com/v2.0/

echo -e "\n --- IMAGE SHARE BETWEEN ACCOUNTS --- \nWhat is your source account username? "
read USERNAME
echo "What is your source account API Key? "
read APIKEY
echo -e "Fetching images, please wait ... \n"

AUTH=$(curl -sX POST $AUTHURL/tokens -d '{ "auth":{ "RAX-KSKEY:apiKeyCredentials":{ "username":"'$USERNAME'", "apiKey":"'$APIKEY'" } } }' -H "Content-type: application/json")
TOKEN=$(echo $AUTH | python -mjson.tool | grep -A5 token | grep id | cut -d '"' -f4)
IMGURL=$(echo $AUTH | python -mjson.tool |grep images | cut -d '"' -f4)


curl -sX GET $IMGURL/images -H "X-Auth-Token: $TOKEN" | python -mjson.tool | grep '"name"\|"id"\|"image_type"' | grep -C1 '"snapshot"' | awk -F'"' '/id/ {print "ID  : " $4} /name/ {print "Name: " $4 "\n"}'

echo "Please give the image ID that you want to share: "
read IMAGEID
echo "What is the destination account number? "
read REC_TENNANT

curl -sX POST $IMGURL/images/$IMAGEID/members -H "Content-type: application/json" -H "X-Auth-Token: $TOKEN" -d '{"member": "'$REC_TENNANT'"}'

echo -e "Now please provide the credentials for receiving account. \nWhat is the destination account username? "
read REC_USERNAME
echo "What is the destination account API Key? "
read REC_APIKEY
echo "Activating image on the receiving account ..."

REC_AUTH=$(curl -sX POST $AUTHURL/tokens -d '{ "auth":{ "RAX-KSKEY:apiKeyCredentials":{ "username":"'$REC_USERNAME'", "apiKey":"'$REC_APIKEY'" } } }' -H "Content-type: application/json")
REC_TOKEN=$(echo $REC_AUTH | python -mjson.tool | grep -A5 token | grep id | cut -d '"' -f4)
REC_IMGURL=$(echo $REC_AUTH | python -mjson.tool |grep images | cut -d '"' -f4)

curl -sX PUT $REC_IMGURL/images/$IMAGEID/members/$REC_TENNANT -H "Content-type: application/json" -H "X-Auth-Token: $REC_TOKEN" -d '{"status": "accepted"}' |python -mjson.tool

echo "Image shared."

