#!/bin/bash

set -euo pipefail

# Capture the start time for Slack notification

export deploy_start=$(date)

cat <<- YAML | buildkite-agent pipeline upload

steps:

- label: "Build and Push Preview Environment Docker Image :docker:"

plugins:

- seek-oss/docker-ecr-publish#v2.4.0:

dockerfile: kintent-sharedinfra/ecr/preview-environment-docker/Dockerfile

add-latest-tag: false

ecr-name: kintent/preview-environment

tags: "${BUILDKITE_COMMIT:0:7}"

notify:

- slack:

channels:

- "#preview-environment-updates"

message: |

Preview Environment Docker Image \`${BUILDKITE_COMMIT:0:7}\` is updated \`\`\`${BUILDKITE_COMMIT:0:7} ${BUILDKITE_MESSAGE}\`\`\`

Deployed by ${BUILDKITE_BUILD_CREATOR} at $deploy_start

YAML
