#!/bin/bash
## Common home startup script run on all operating systems on all platforms

echo "=== metadata-script.sh $(date)"

if [ -b /dev/nvme0n1 ] ; then
    echo "+++ building /scratch"
    apt-get install --no-install-recommends -y mdadm
    mdadm -v --create /dev/md0 --level=0 -n$(echo /dev/nvme0n* | wc -w) /dev/nvme0n*
    mke2fs -T ext4 /dev/md0
    install -dv /scratch
    mount /dev/md0 /scratch
    chmod 1777 /scratch
    df -h /scratch
fi

echo "=== metadata-script.sh $(date) done"
