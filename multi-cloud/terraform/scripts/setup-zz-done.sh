#!/bin/bash

echo "=== setup-zero-done.sh $(hostname) $(date)"

if [ -r  /var/run/reboot-required ] ; then
    echo "+++ rebooting"
    sudo systemctl reboot
fi
