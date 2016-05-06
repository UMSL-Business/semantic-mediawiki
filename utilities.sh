#!/bin/bash
#:#########################################################################
#: Intent: A collection of helper functions to:
#:	- output settings variables
#:	- check status of stack creation
#:
#: Requires:
#:	- aws-cli installed and configured
#:	- jq
#:	- settings.sh
#:
#:##########################################################################

function check_stack_status() {
	log_msg "Current status of "$1
	while [[ 1 ]]; do
		local stack_status=$(aws \
				--profile $settings_aws_cli_profile \
				--output json \
				--region $settings_region \
				cloudformation describe-stack-events \
				--stack-name $1 | \
				jq --arg jq_stack_name "$1" '.StackEvents[] | select(.LogicalResourceId == $jq_stack_name) | .ResourceStatus' | head -1 | sed "s/\"//g")

	  if [[ $stack_status == "CREATE_COMPLETE" ]]; then
	  	break
	  elif [[ $stack_status == "CREATE_FAILED" ]]; then
	  	log_msg "FAILED:  create stack:  $1"
	  	exit 1
		elif [[ $stack_status == "ROLLBACK_COMPLETE" ]]; then
	  	log_msg "FAILED:  update stack:  $1"
	  	exit 1
		elif [[ $stack_status == "UPDATE_ROLLBACK_COMPLETE" ]]; then
	  	log_msg "FAILED:  update stack:  $1"
	  	exit 1
		elif [[ $stack_status == "UPDATE_COMPLETE" ]]; then
	  	break
	  else
	  	log_msg "STACK STATUS - $1:  $stack_status"
	  	sleep 15
	  fi
	done

	log_msg "STACK STATUS - $1:  $stack_status"
}

function clear_screen() {
	printf "\033c"
}

# Parameters:
# $1: cloudformation stack name
# $2: cloudformation template local file path
# $3: cloudformation master template name
# $4: cloudformation stack parameters
#
# Usage:
# create_stack "conductor-stack" "/Users/grhick/Projects/conductor-aws-automation/master.json" "ParameterKey=KeyPairName,ParameterValue=MyKey ParameterKey=InstanceType,ParameterValue=t1.micro"
function create_stack() {
	aws --profile $settings_aws_cli_profile \
		--output json \
		--region $settings_region \
		--color on \
		cloudformation create-stack \
		--stack-name $1 \
		--template-body file://$2/$3 \
		--parameters $4 \
		--capabilities CAPABILITY_IAM \
		--tags $settings_tags_params \
		|| { log_msg "FAIL:  could not create stack - $1"; exit 1;}
}

# Parameters:
# $1: message string
#
# Usage:
# log_msg "test message"
function log_msg() {
	# "$@" is an array-like construct of all positional parameters, {$1, $2, $3 ...}
	if [ -n "$@" ]
  then
  	IN="$@"
  else
    read IN # This reads a string from stdin and stores it in a variable called IN
  fi

	DATEFMT=`date "+%m/%d/%Y %H:%M:%S"`
	echo "$DATEFMT: $IN" | tee -a $settings_log_file_path
}

function print_divider() {
	printf '%.s*' {1..120}; printf "\n"
}

# Parameters:
# $1: Header message
#
# Usage:
# print_intro "Custom Message"
function print_intro() {
	print_divider

	# print settings_ variables
	echo $1
	( set -o posix ; set ) | grep settings_
}

# Parameters:
# $1: cloudformation stack name
# $2: cloudformation stack file path to local templates for upload to s3
# $3: cloudformation stack master template
# $4: s3 bucket path for template upload or "false" if not uploading templates to s3
# $5: stack parameters (ensure variable in surrounded with quotes due to spaces in the settings_*_params list)
#
# Usage:
# setup_stack "Custom Message"
function setup_stack() {
	log_msg "validating templates for stack: $1"
	validate_templates $2 "json"

	log_msg "uploading templates to s3 for stack: $1"
  upload_templates $2 $4

	log_msg "Check if stack, $1, exists"
	local exit_code="0"
	aws --profile $settings_aws_cli_profile \
		--output json \
		--region $settings_region \
		cloudformation describe-stack-events \
		--stack-name $1 &>/dev/null \
		|| { exit_code=$?; }
	if [ $exit_code -gt "0" ]; then
		log_msg "stack, $1, does not exist"
		log_msg "create stack: $1"
		create_stack $1 $2 $3 "$5"
	else
		log_msg "stack, $1, exists"
		log_msg "update stack: $1"
		update_stack $1 $2 $3 "$5"
	fi

	check_stack_status $1
}

# Parameters:
# $1: cloudformation stack name
# $2: cloudformation template local file path
# $3: cloudformation master template name
# $4: cloudformation stack parameters
#
# Usage:
# update_stack "conductor-stack" "/Users/grhick/Projects/conductor-aws-automation/master.json" "ParameterKey=KeyPairName,ParameterValue=MyKey ParameterKey=InstanceType,ParameterValue=t1.micro"
function update_stack() {
	aws --profile $settings_aws_cli_profile \
		--output table \
		--region $settings_region \
		cloudformation update-stack \
		--stack-name $1 \
		--template-body file://$2/$3 \
		--parameters $4 \
		--capabilities CAPABILITY_IAM \
		|| { log_msg "FAIL:  could not update stack - $1";}
}

# Parameters:
# $1: file path to cloudformation stack templates
# $2: "true"/"false" on whether to upload templates to s3
#			OR s3 bucketname plus optional folder within bucket
#
# Usage:
# upload_templates "true" $settings_prelim_stack_path "$settings_prelim_s3repos_cftemplates_bucketname/preliminaries"
function upload_templates() {
	if [[ $2 == "false" ]]; then
		break
	else
		aws --profile $settings_aws_cli_profile \
			s3 sync $1 s3://$2 \
			--exclude "*.sh" --exclude "*-cloudformation-parameters" || { log_msg "Could not upload templates to s3://$2. Does the bucket exist?"; exit 1;}
	fi
}

# Parameters:
# $1: file path to cloudformation stack templates
# $2: file or file type to validate
#
# Usage:
# validate_templates $settings_prelim_s3repos_stack_path $settings_prelim_s3repos_master_template
function validate_templates() {
	print_divider

	local files=$(ls $1 | grep "$2")
	for file in $files
	do
		aws --output table \
			--region $settings_region \
			cloudformation validate-template \
			--template-body file://$1$file || { log_msg "Failed to validate file://$1$file"; exit 1;}
		print_divider
	done
}
