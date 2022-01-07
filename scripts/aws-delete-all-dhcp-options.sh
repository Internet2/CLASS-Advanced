#!/bin/bash

# you can get this back by running `aws ec2 create-default-vpc`

profile=$1
if [ -z "$profile" ] ; then
    echo "aws-delete-all-dhcp-options.sh profile"
    exit 1
fi
AWS="aws --profile $profile"
OUTPUT="--output=text --no-cli-pager"
echo "=== aws-delete-all-dhcp-options.sh"

regions=$($AWS ec2 describe-regions --query='Regions[].[RegionName]' $OUTPUT)
for region in ${regions[@]} ; do
    echo "+++ $region"
    dhcp_options=$($AWS ec2 describe-dhcp-options --region=$region --query=DhcpOptions[].DhcpOptionsId $OUTPUT)
    if [ -n "$dhcp_options" ] ; then
        echo "--- $region $dhcp_options"
        $AWS ec2 delete-dhcp-options --region=$region --dhcp-options-id=$dhcp_options
    fi
done
