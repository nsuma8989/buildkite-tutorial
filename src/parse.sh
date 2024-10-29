#!/bin/bash

# Define or retrieve the comma-separated list of services dynamically
# You can replace this with a dynamic source, e.g., an environment variable
SERVICES="service-a,service-b,service-c"

# Split the SERVICES variable into an array
IFS=',' read -r -a service_array <<< "$SERVICES"

# Start the pipeline YAML with the matrix setup
echo "steps:" > pipeline.yml
echo "  - label: \"Run Tests with each service\"" >> pipeline.yml
echo "    command: \"echo Running tests for \$SERVICE\"" >> pipeline.yml
echo "    matrix:" >> pipeline.yml
echo "      setup:" >> pipeline.yml
echo "        service:" >> pipeline.yml

# Add each service as a separate entry in the matrix
for service in "${service_array[@]}"; do
  echo "          - \"$service\"" >> pipeline.yml
done

# Set the environment variable to reference the matrix value
echo "    env:" >> pipeline.yml
echo "      SERVICE: \"{{matrix.setup.service}}\"" >> pipeline.yml
# Upload the dynamically generated pipeline to Buildkite
buildkite-agent pipeline upload pipeline.yml
