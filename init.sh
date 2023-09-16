#!/bin/bash

POD_ID="${HOSTNAME##*-}"
echo "POD_ID: $POD_ID"

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
echo "NAMESPACE: $NAMESPACE"

POD_DNS=mongodb-${NAMESPACE}-sts-${POD_ID}.mongodb-${NAMESPACE}-srv.${NAMESPACE}.svc.cluster.local
echo "POD_DNS: $POD_DNS"

DB_PATH=/data/db
echo "DB_PATH: $DB_PATH"

if [ "$DB_TYPE" == "STANDALONE" ]; then
    mongod --port 27017 --bind_ip localhost,${POD_DNS} --dbpath ${DB_PATH} --oplogSize 128
    exit 0
fi



KEYFILE_PATH="/root/keyfile"

while [ ! -e "$KEYFILE_PATH" ]; do
    echo "File does not exist. Waiting..."
    sleep 1  # You can adjust the sleep duration as needed
done

echo "$KEYFILE_PATH exists. Continue configuring replication..."

# Start mongo as a replica set
mongod --keyFile $KEYFILE_PATH --replSet $REPLSET_NAME --port 27017 --bind_ip localhost,${POD_DNS} --dbpath ${DB_PATH} --oplogSize 128
sleep 5