#!/bin/bash
set -euo pipefail

TAG="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)-${BUILDKITE_BUILD_NUMBER:-0}"
IMG="packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/hello-kaniko:${TAG}"

# Use debug image if KANIKO_DEBUG is set
if [[ "${KANIKO_DEBUG:-false}" =~ (true|on|1) ]]; then
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0-debug}"
else
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0}"
fi

ORG="${BUILDKITE_ORGANIZATION_SLUG}"
REG="${PACKAGE_REGISTRY_NAME}"
REG_URL="packages.buildkite.com/${ORG}/${REG}"

echo "~~~ Configure OIDC token"

# 1) Request a short-lived OIDC token (aud must be the registry URL)
OIDC_TOKEN="$(buildkite-agent oidc request-token \
  --audience "https://packages.buildkite.com/${ORG}/${REG}" \
  --lifetime 300)"

# 2) Write Kaniko's Docker config with the OIDC token
#    Username must be "buildkite" for OIDC auth.
cat > config.json <<JSON
{
  "auths": {
    "${REG_URL}": {
      "username": "buildkite",
      "password": "${OIDC_TOKEN}"
    }
  }
}
JSON

echo "~~~ Building image using kaniko: ${IMG}"

# 3) Run Kaniko and push directly
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/config.json":/kaniko/.docker/config.json:ro \
  "${KANIKO}" \
  --dockerfile=/workspace/Dockerfile \
  --context=dir:///workspace \
  --destination="${IMG}" \
  --verbosity=info \
  --log-timestamp \
  --cache=true \
  --cache-repo="packages.buildkite.com/${ORG}/${REG}/hello-kaniko-cache"

# 4) Pull and run image built by Kaniko using the same OIDC token
echo "~~~ :docker: Pulling image: ${IMG}"
DOCKER_CONFIG="$PWD" docker pull "${IMG}"
echo "~~~ :docker: Running image: ${IMG}"
DOCKER_CONFIG="$PWD" docker run --rm "${IMG}"

