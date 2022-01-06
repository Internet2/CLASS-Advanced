#!/bin/bash
set -e

profile=$1
if [ -z "$profile" ] ; then
    echo "azure-list.sh profile"
    exit 1
fi

AZ="az"
OPTIONS="--subscription=$profile --output=tsv"

echo "=== azure-list.sh $profile"
$AZ account show $OPTIONS
#$AZ group list $OPTIONS
$AZ vm list --query='[].{name:name,location:location,group:resourceGroup}' $OPTIONS
$AZ network public-ip list --query='[].{name:name,location:location,group:resourceGroup,ip:ipAddress}' $OPTIONS
$AZ disk list --query='[].{name:name,location:location,group:resourceGroup,size:diskSizeGb}' $OPTIONS
