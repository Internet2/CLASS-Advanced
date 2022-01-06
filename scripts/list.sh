#!/bin/bash
set -e

clouds=(aws azure gcp)
SCRIPTS=$(dirname "$0")

profile=$1
if [ -z "$profile" ] ; then
    echo "cloud-list.sh profile"
    exit 1
fi

for cloud in ${clouds[@]} ; do
    $SCRIPTS/$cloud-list.sh $profile
done
