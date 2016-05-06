#!/bin/bash
#:#########################################################################
#: Intent: Upload resource files to s3://smw-resources-$ENV
#:    - ec2 bootstrap scripts
#:
#: Dependencies:
#:    - s3://smw-resources-$ENV exists
#:##########################################################################

function main() {
  CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
  source "$CURRENT_DIR/../settings.sh"
  source "$CURRENT_DIR/../utilities.sh"

  aws --profile $settings_aws_cli_profile \
    s3 sync $CURRENT_DIR s3://$settings_prelim_s3repos_resources_bucketname \
    --exclude "upload-bootstrap-files.sh" \
    || { echo "Could not upload resource files to s3://$settings_prelim_s3repos_resources_bucketname. Does the bucket exist?"; exit 1;}
}

main
