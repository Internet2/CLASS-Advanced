#!/bin/bash

echo "=== setup-prox.sh $(hostname) $(date)"

if ! grep -q "^# local configuration" /etc/hosts ; then
    echo -e '\n# local configuration' |sudo tee -a /etc/hosts
    echo '127.0.0.1 proxy' |sudo tee -a /etc/hosts
    echo '::1 ipv6-proxy' |sudo tee -a /etc/hosts
fi
