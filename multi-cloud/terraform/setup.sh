#!/bin/bash

ZERO_IP4=$(terraform output --raw zero_ipv4)
ssh-keygen -R $ZERO_IP4

# Note the order of the scripts is alphabetic
cat scripts/setup-*.sh | ssh $ZERO_IP4
