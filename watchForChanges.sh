#!/bin/bash

echo "Starting the watch-swagger script."

# Define the path to the Swagger YAML file and the generate.sh script
SWAGGER_PATH="/Users/coltonhillebrand/Documents/github/MTHAccountingTest/GeneratedClient/ClientFiles/openapi.yaml"
GENERATE_SCRIPT="/Users/coltonhillebrand/Documents/github/swift-openapi-generator/generate.sh"

echo "Will watch for changes in $SWAGGER_PATH"
echo "Will execute $GENERATE_SCRIPT when changes are detected."

# Use fswatch to monitor the Swagger YAML file and trigger the generate.sh script upon changes
fswatch -v -o "$SWAGGER_PATH" | xargs -n1 -I{} sh -c "$GENERATE_SCRIPT; echo 'generate.sh has been executed.'"
