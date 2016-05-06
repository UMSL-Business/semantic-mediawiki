#!/bin/bash
#:#########################################################################
#: Intent: This is the main script to create the Semantic MediaWiki Environment in AWS
#:
#: Requires:
#: 	settings.sh
#:		- contains parameters (bucket names, stack name, tags, etc)
#:			used in the Cloudformation create-stack call)
#:	utilities.sh (contains helper functions)
#:
#:##########################################################################

setup-preliminaries() {
  log_msg "START:  setup of preliminary project resources"
  sh ./preliminaries/setup-preliminaries.sh
  log_msg "END:  setup of preliminary project resources"
}

setup-vpc() {
  log_msg "START:  setup of project VPC resources"
  sh ./resources/upload-bootstrap-files.sh
  sh ./vpc/setup-vpc-stack.sh
  log_msg "END:  setup of project VPC resources"
}

function main() {
  source settings.sh
  source utilities.sh

  clear_screen

  FAIL_MSG="FAIL: pass option to build one of: [ prelim | vpc | all]"

  if [ "$1" == "preliminaries" ] || [ "$1" == "prelim" ]; then
    setup-preliminaries
  elif [ "$1" == "vpc" ]; then
    setup-vpc
  elif [ "$1" == "all" ]; then
    setup-preliminaries
    setup-vpc
  else
    echo $FAIL_MSG; exit 1
  fi
}

main $1
