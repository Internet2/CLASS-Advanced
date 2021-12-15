#!/bin/bash

exec ssh -t -D 8180 $(terraform output --raw zero_ipv4) $*


