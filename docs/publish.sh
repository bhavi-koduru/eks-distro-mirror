#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ "$AWS_ROLE_ARN" == "" ]; then
    echo "Empty AWS_ROLE_ARN, this script must be run in a postsubmit pod with IAM Roles for Service Accounts"
    exit 1
fi

cat << EOF > config
[default]
output = json
region = us-west-2
role_arn=$AWS_ROLE_ARN
web_identity_token_file=/var/run/secrets/eks.amazonaws.com/serviceaccount/token

[profile release-prod]
role_arn = arn:aws:iam::379412251201:role/DocsDeploymentRole
region = us-east-1
source_profile=default
EOF

BUCKET_NAME=artifactsstack-379412251201-docsbucketecea003f-bhslmuf2xe3m
DISTRIBUTION_ID=${DISTRIBUTION_ID:-"E1G9R70424D2RN"}

export AWS_CONFIG_FILE=$(pwd)/config
export AWS_DEFAULT_PROFILE=release-prod

aws s3 sync --acl public-read ./site s3://${BUCKET_NAME}
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/404.html" "/assets/" "/community/" "/index.html" "/search/" "/sitemap.xml" "/sitemap.xml.gz" "/users/"
