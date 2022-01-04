#!/bin/bash

## Local auto tfvars for entire project.
tfvars=( username ssh_public_key aws_region aws_credentials azure_tenant azure_subscription azure_credentials gcp_zone gcp_project gcp_credentials )

if [ ! -r secrets/local.auto.tfvars ] ; then
  install -dv secrets/
  for tfvar in ${tfvars[@]} ; do
    echo "${tfvar}=\"\"" >> secrets/local.auto.tfvars
    done
fi
