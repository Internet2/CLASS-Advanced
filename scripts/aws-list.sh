#!/bin/bash
set -e

profile=$1
if [ -z "$profile" ] ; then
    echo "aws-list.sh profile"
    exit 1
fi

REGIONS=( us-east-1 us-east-2 us-west-1 us-west-2 )
AWS="aws --profile $profile --output text --no-cli-pager"

echo "=== aws-list.sh $profile"
aws --profile $profile sts get-caller-identity --output text --no-cli-pager

for REGION in ${REGIONS[@]} ; do
    #echo "--- $REGION"
    # Additinal Fields: InstanceId
    $AWS ec2 describe-instances \
        --filter 'Name=instance-state-name,Values=pending,running,shutting-down,stopping,stopped' \
        --query 'Reservations[].Instances[*].[KeyName,Placement.AvailabilityZone,PublicIpAddress,Ipv6Address,InstanceType]' \
        --region $REGION
done
