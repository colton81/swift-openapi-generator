#!/bin/bash

# Define the output directory and the location of the openapi.yaml file

OUTPUT_DIRECTORY="/Users/coltonhillebrand/Documents/github/MTHAccountingTest/MTHAccountingTest/Helpers/APIManager/ClientFiles"
#OUTPUT_DIRECTORY="/Users/coltonhillebrand/Documents/github/ERP-IOS/ERPProject/MTH Accounting/Utilities/APIServices/APIGenerated"
OPENAPI_YAML_PATH="$OUTPUT_DIRECTORY/openapi.yaml"


# Check if openapi.yaml file exists
if [ ! -f "$OPENAPI_YAML_PATH" ]; then
  echo "Error: openapi.yaml file not found at $OPENAPI_YAML_PATH"
  exit 1
fi

# Run the swift-openapi-generator command
swift run swift-openapi-generator generate \
  --mode types \
  --mode client \
  --additional-import Foundation \
  --output-directory "$OUTPUT_DIRECTORY" \
  "$OPENAPI_YAML_PATH"

# Check if the command was successful
if [ $? -eq 0 ]; then
  echo "API client and types successfully generated."
else
  echo "An error occurred during generation. Please check your configuration."
  exit 1
fi
