#!/bin/bash
#:#########################################################################
#: Intent: This script creates a CF stack that will provision the following
#:            for the SMW environment:
#:              - S3 buckets to hold the VPC Cloudformation templates and needed resources
#:
#: Notes:
#:	The s3 bucket name cannot already exist prior to running this script.
#: 	settings.sh
#:		- contains parameters (bucket names, stack name, tags, etc)
#:			used in the Cloudformation create-stack call)
#:	utilities.sh (contains helper functions)
#:
#:##########################################################################

function main() {
  CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  source "$CURRENT_DIR/../settings.sh"
  source "$CURRENT_DIR/../utilities.sh"

   # provision cloudformation stack to create s3 buckets for template uploads and smw resources
   log_msg "START:  create cloudformation stack - $settings_prelim_s3repos_stack_name"
   setup_stack \
    $settings_prelim_s3repos_stack_name \
    $settings_prelim_s3repos_stack_path \
    $settings_prelim_s3repos_master_template \
    "false" \
    "$settings_prelim_s3repos_params"
   log_msg "END:  create cloudformation stack - $settings_prelim_s3repos_stack_name"
}

main
