#!/bin/bash
#:#########################################################################
#: Intent: 	This script creates a nested CloudFormation stack that stands up the
#:						Semantic MediaWiki VPC environment
#:
#: Inputs:
#:	none
#:
#: Dependencies:
#:	- aws-cli installed and configured
#:	- email address to send ec2 autoscaling group notifications
#: 	- The S3 bucket (s3://$settings_prelim_s3repos_cftemplates_bucketname/vpc) that houses the templates must exist.
#:	- valid ec2 keypair.
#:	- ../settings.sh
#:	- ../utilities.sh
#:
#:##########################################################################

function main() {
	CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  source "$CURRENT_DIR/../settings.sh"
  source "$CURRENT_DIR/../utilities.sh"

	# provision cloudformation stack to create the vpc environment
  log_msg "START:  create cloudformation stack - $settings_vpc_stack_name"

	setup_stack \
    $settings_vpc_stack_name \
    $settings_vpc_stack_path \
    $settings_vpc_master_template \
    "$settings_prelim_s3repos_cftemplates_bucketname/vpc/" \
    "$settings_vpc_params"

	log_msg "END:  create cloudformation stack - $settings_vpc_stack_name"
}

main
