#!/bin/bash

## Local auto tfvars for entire project.
tfvars=( username ssh_public_key aws_region azure_tenant azure_subscription gcp_project gcp_zone )

if [ ! -r secrets/local.auto.tfvars ] ; then
  install -dv secrets/
  for tfvar in ${tfvars[@]} ; do
    echo "${tfvar}=\"\"" >> secrets/local.auto.tfvars
    done
fi
