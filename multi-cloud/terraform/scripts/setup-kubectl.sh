#!/bin/bash

if [ -x /usr/bin/apt-get -a -x /usr/bin/sudo ] ; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes kubectl
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes docker.io
fi

CLUSTER=zero-container-cluster
ZONE=$(gcloud container clusters list --filter=name=$CLUSTER --format='value(location)')

if [ -x /usr/bin/gcloud ] ; then
    gcloud container clusters get-credentials $CLUSTER --zone=$ZONE
fi

sudo usermod -a -G docker $USER

echo 'source <(kubectl completion bash)' >>~/.bashrc
