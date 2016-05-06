#!/bin/bash
#:#########################################################################
#: Intent: This script sets the required variables for shell scripts
#: 	responsible for creating the environment for Semantic MediaWiki.
#:
#: Dependencies:
#:  aws-cli installed and configured
#:	utilities.sh
#:##########################################################################

source utilities.sh

#: GLOBAL SETTINGS
#:##########################################################################
  # Define Tags
    # environment
      settings_tag_environment="dev"
    # group
      settings_tag_group="IS6891"
    # project
      settings_tag_project="SMW"
    #owner
      settings_tag_owner="UMSL"

  # AWS CLI parameters
    settings_aws_cli_profile="cbd"
    settings_region="us-east-1"

    settings_tags_param1="Key=\"group\",Value=\"$settings_tag_group\""
    settings_tags_param2="Key=\"project\",Value=\"$settings_tag_project\""
    settings_tags_param3="Key=\"environment\",Value=\"$settings_tag_environment\""
    settings_tags_param4="Key=\"owner\",Value=\"$settings_tag_owner\""

    settings_tags_params=$(printf "%s %s %s %s" \
      $settings_tags_param1 \
      $settings_tags_param2 \
      $settings_tags_param3 \
      $settings_tags_param4)

    settings_running_dir=$(pwd)
    settings_log_file_path="./logs/automation.log"

##########################################################################

#: setup-preliminaries.sh
#:##########################################################################
#: Define stack settings/parameters for preliminaries/s3-repos
  settings_prelim_s3repos_stack_name="smw-preliminaries-s3repos-$settings_tag_environment"
  settings_prelim_s3repos_master_template="master.json"
  settings_prelim_s3repos_stack_path="$settings_running_dir/preliminaries/"
  settings_prelim_s3repos_cftemplates_bucketname="smw-cf-templates-$settings_tag_environment"
  settings_prelim_s3repos_resources_bucketname="smw-resources-$settings_tag_environment"

  settings_prelim_s3repos_param1="ParameterKey=StackName,ParameterValue=$settings_prelim_s3repos_stack_name"
  settings_prelim_s3repos_param2="ParameterKey=ProjectTag,ParameterValue=$settings_tag_project"
  settings_prelim_s3repos_param3="ParameterKey=GroupTag,ParameterValue=$settings_tag_group"
  settings_prelim_s3repos_param4="ParameterKey=EnvironmentTag,ParameterValue=$settings_tag_environment"
  settings_prelim_s3repos_param5="ParameterKey=OwnerTag,ParameterValue=$settings_tag_owner"
  settings_prelim_s3repos_param6="ParameterKey=CFTemplateBucketName,ParameterValue=$settings_prelim_s3repos_cftemplates_bucketname"
  settings_prelim_s3repos_param7="ParameterKey=ResourcesBucketName,ParameterValue=$settings_prelim_s3repos_resources_bucketname"

  settings_prelim_s3repos_params=$(printf "%s %s %s %s %s %s %s" \
    $settings_prelim_s3repos_param1 \
    $settings_prelim_s3repos_param2 \
    $settings_prelim_s3repos_param3 \
    $settings_prelim_s3repos_param4 \
    $settings_prelim_s3repos_param5 \
    $settings_prelim_s3repos_param6 \
    $settings_prelim_s3repos_param7)

##########################################################################



#: setup-vpc-stack.sh
#:##########################################################################
  # Define stack settings/parameters
    settings_vpc_stack_name="smw-vpc-$settings_tag_environment"
    settings_vpc_stack_path="$settings_running_dir/vpc/"
    settings_vpc_master_template="master.json"

  # EC2 KeyPair name that already exists
    settings_keyName="GH-keypair-useast1"

  # Define VPC CIDR blocks and static IP addresses
    settings_VPC_CIDR="89.1.0.0/16"
    settings_PublicSubnetCIDR="89.1.1.0/24"

  # EC2 instance types
    settings_smw_instance_type="t2.micro"

  # SNS Topic to handle ec2 asg notifications
    settings_sns_ec2_notification="smw-ec2Topic-$settings_tag_environment"
    settings_sns_email_subscriber="grh6q4@mail.umsl.edu"

  settings_vpc_param1="ParameterKey=StackName,ParameterValue=$settings_vpc_stack_name"
  settings_vpc_param2="ParameterKey=ProjectTag,ParameterValue=$settings_tag_project"
  settings_vpc_param3="ParameterKey=GroupTag,ParameterValue=$settings_tag_group"
  settings_vpc_param4="ParameterKey=EnvironmentTag,ParameterValue=$settings_tag_environment"
  settings_vpc_param5="ParameterKey=OwnerTag,ParameterValue=$settings_tag_owner"
  settings_vpc_param6="ParameterKey=VPCCidr,ParameterValue=$settings_VPC_CIDR"
  settings_vpc_param7="ParameterKey=PublicSubnetCIDR,ParameterValue=$settings_PublicSubnetCIDR"
  settings_vpc_param8="ParameterKey=InstanceTypeSMW,ParameterValue=$settings_smw_instance_type"
  settings_vpc_param9="ParameterKey=KeyName,ParameterValue=$settings_keyName"
  settings_vpc_param10="ParameterKey=SNSTopicName,ParameterValue=$settings_sns_ec2_notification"
  settings_vpc_param11="ParameterKey=SNSTopicEmailSubscriber,ParameterValue=$settings_sns_email_subscriber"
  settings_vpc_param12="ParameterKey=ResourcesBucketName,ParameterValue=$settings_prelim_s3repos_resources_bucketname"

  settings_vpc_params=$(printf "%s %s %s %s %s %s %s %s %s %s %s %s" \
    $settings_vpc_param1 \
    $settings_vpc_param2 \
    $settings_vpc_param3 \
    $settings_vpc_param4 \
    $settings_vpc_param5 \
    $settings_vpc_param6 \
    $settings_vpc_param7 \
    $settings_vpc_param8 \
    $settings_vpc_param9 \
    $settings_vpc_param10 \
    $settings_vpc_param11 \
    $settings_vpc_param12)
##########################################################################
