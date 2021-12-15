#!/bin/bash

## Local auto tfvars for entire project.
local=( username ssh_public_key )

if [ ! -r local/local.auto.tfvars ] ; then
  for tfvar in ${local[@]} ; do
    echo "${tfvar}=\"\"" >> local/local.auto.tfvars
    done
fi
