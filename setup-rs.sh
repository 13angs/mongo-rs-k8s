#!/bin/bash

POD_ID="${HOSTNAME##*-}"
echo "POD_ID: $POD_ID"

echo "Configuring $HOSTNAME as primary..."

# if [ "$POD_ID" -ne 0 ]; then
#     echo "This member is not a primary db."
#     exit 0
# fi

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
echo "NAMESPACE: $NAMESPACE"

STS_DNS=mongodb-${NAMESPACE}-srv.${NAMESPACE}.svc.cluster.local:27017
echo "STS_DNS: $STS_DNS"

# start configuring the primary db
STS_NAME="${HOSTNAME%-0}"
echo "STS_NAME: $STS_NAME"

POD_DNS_0=${STS_NAME}-0.${STS_DNS}
POD_DNS_1=${STS_NAME}-1.${STS_DNS}
POD_DNS_2=${STS_NAME}-2.${STS_DNS}

function init_repl_set(){
    mongosh --quiet --eval "MEMBERS=['$POD_DNS_0','$POD_DNS_1','$POD_DNS_2']" --shell << EOL
    rs.initiate( {
        _id : "rs0",
        members: [
            { _id: 0, host: MEMBERS[0] },
            { _id: 1, host: MEMBERS[1] },
            { _id: 2, host: MEMBERS[2] }
        ]
    })
EOL
}

init_repl_set
