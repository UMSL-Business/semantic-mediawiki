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
# download docker jenkins image from S3
# install and configure jenkins via docker container
#
# Parameters:
# $1: S3 bucket for conductor-resources-$ENV
#
# Usage:
# setup_jenkins $S3_BUCKET
function setup_smw() {
  echo "wip"
  # download jenkins docker image from s3
  ##aws s3 --region $LOCAL_REGION cp s3://$1/jenkins-ci/jenkins-docker.tar /tmp

  # load jenkins docker image
  ##docker load < /tmp/jenkins-docker.tar

  # start docker container
  ##mkdir -p /var/lib/jenkins
  ##chown -R 1000:1000 /var/lib/jenkins
  ##docker run --net=host -d -v /var/lib/jenkins:/var/jenkins_home -e JENKINS_OPTS="--prefix=/release" jenkins
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
