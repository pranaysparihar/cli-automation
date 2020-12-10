#!/bin/bash
	
vpcID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query Vpc.VpcId --output text`
echo $vpcID
subnetID=`aws ec2 create-subnet --vpc-id $vpcID --cidr-block 10.0.1.0/24 --query Subnet.SubnetId --output text`
echo $subnetID
igwID=`aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text`
echo $igwID
aws ec2 attach-internet-gateway --vpc-id $vpcID --internet-gateway-id $igwID
rtbID=`aws ec2 create-route-table --vpc-id $vpcID --query RouteTable.RouteTableId --output text`
echo $rtbID
aws ec2 create-route --route-table-id $rtbID --destination-cidr-block 0.0.0.0/0 --gateway-id $igwID
aws ec2 associate-route-table  --subnet-id $subnetID --route-table-id $rtbID
aws ec2 modify-subnet-attribute --subnet-id $subnetID --map-public-ip-on-launch

aws ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $vpcID 
sgID=`aws ec2 describe-security-groups --filter Name=vpc-id,Values=$vpcID Name=group-name,Values=SSHAccess --query 'SecurityGroups[*].[GroupId]' --output text`
echo $sgID
aws ec2 authorize-security-group-ingress --group-id $sgID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 run-instances --image-id ami-026669ec456129a70 --count 1 --instance-type t2.micro --key-name MyKeyPair --security-group-ids $sgID --subnet-id $subnetID




