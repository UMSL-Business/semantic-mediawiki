#!/bin/bash
#:#########################################################################
#: Intent: Bootstrap the Semantic MediaWiki box
#:      - Associate EIP with jumpbox (intended to be one instance within ASG of min: 1, max: 1 instances)
#:      - install and configure Semantic MediaWiki (SMW)
#:
#: Dependencies:
#:    - s3://smw-resources-$ENV exists
#:    - jq installed on instance
#:##########################################################################

# Purpose:
# associate smw instance with SMWEIP
#
# Parameters:
# $1: EIP ID to associate with instance
#
# Usage:
# associate_EIP_with_instance $EIP_ID
function associate_EIP_with_instance() {
  aws ec2 associate-address --region $LOCAL_REGION \
    --instance-id $LOCAL_INSTANCE_ID \
    --allocation-id $1
}

function setup_docker() {
  # install docker
  yum install -y docker

  # start the docker service
  service docker start

  # Add the ec2-user to the docker group so you can execute Docker commands without using sudo
  sudo usermod -a -G docker ec2-user
}

# Purpose:
# download resources for install semantic mediawiki
# install and configure semantic mediawiki via docker container
#
# Parameters:
# $1: S3 bucket for smw-resources-dev
#
# Usage:
# setup_jenkins $S3_BUCKET
function setup_smw() {
  # download resources for install semantic mediawiki
  aws s3 --region $LOCAL_REGION sync s3://$1/smw /tmp --exclude "bootstrap-smw.sh" --exclude "mediawiki-1.26.2.tar.gz"

  cd /tmp
  docker build -t is6891/smw:v1 .
  
}

# Parameters:
# $1: EIP ID to associate with instance
# $2: S3 bucket name for smw-resources-$ENV
#
# Usage:
# associate_EIP_with_instance $EIP_ID $S3_BUCKET
function main() {
  # capture the region and instanceID of the EC2 box
  LOCAL_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document/ | jq -r .region)
  LOCAL_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document/ | jq -r .instanceId)

  # Update the installed packages and package cache on your instance.
  yum update -y

  associate_EIP_with_instance $1
  setup_docker
  setup_smw $2
}

main $1 $2
