#!/bin/bash
set -e

profile=$1
if [ -z "$profile" ] ; then
    echo "gcp-list.sh profile"
    exit 1
fi

GCLOUD="gcloud --configuration=$profile --format=[no-heading]"

echo "=== gcp-list.sh $profile"
gcloud config get-value project
PROJECT=$(gcloud --configuration=$profile config list --format='value(core.project)')

$GCLOUD compute instances list
$GCLOUD compute disks list
$GCLOUD container clusters list
$GCLOUD --verbosity=none alpha storage ls
$GCLOUD container images list --repository gcr.io/$PROJECT
$GCLOUD --verbosity=none beta artifacts repositories list
