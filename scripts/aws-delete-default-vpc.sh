#!/bin/bash

# you can get this back by running `aws ec2 create-default-vpc`

profile=$1
if [ -z "$profile" ] ; then
    echo "aws-delete-default-vpc.sh profile"
    exit 1
fi
AWS="aws --profile $profile"
OUTPUT="--output=text --no-cli-pager"
echo "=== aws-delete-default-vpc.sh"

regions=$($AWS ec2 describe-regions --query='Regions[].[RegionName]' $OUTPUT)
for region in ${regions[@]} ; do
    echo "+++ $region"
    default_vpcs=$($AWS ec2 describe-vpcs --region=$region --filter='Name=is-default,Values=true' --query=Vpcs[].VpcId $OUTPUT)
    for vpc in ${default_vpcs[@]} ; do
        echo "--- $vpc"

        internet_gateway=$($AWS ec2 describe-internet-gateways --region=$region --filters "Name=attachment.vpc-id,Values=$vpc" --query "InternetGateways[].InternetGatewayId" $OUTPUT)
        echo "--- $vpc $internet_gateway"
        if [ -n "$internet_gateway" ] ; then
            $AWS ec2 detach-internet-gateway --region=$region --internet-gateway-id=$internet_gateway --vpc-id=$vpc $OUTPUT
            $AWS ec2 delete-internet-gateway --region=$region --internet-gateway-id=$internet_gateway $OUTPUT
        fi

        default_subnets=$($AWS ec2 describe-subnets --region=$region --filter="Name=vpc-id,Values=$vpc" --filter="Name=default-for-az,Values=true" --query=Subnets[].SubnetId $OUTPUT)
        for subnet in ${default_subnets[@]} ; do 
            echo "--- $vpc $subnet"
            $AWS ec2 delete-subnet --region=$region --subnet-id=$subnet
        done

        $AWS ec2 delete-vpc --region=$region --vpc-id $vpc 
    done

done
