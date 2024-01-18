#!/bin/bash

# Ask user to select the working directory
echo "Please select the working directory:"
echo "1) OUTPUT_DIRECTORY"
echo "2) OUTPUT_DIRECTORY_WORK"
read -p "Enter your choice (1/2): " choice

# Define the output directory based on user selection
case $choice in
  1)
    OUTPUT_DIRECTORY="/Users/coltonhillebrand/Documents/github/ERP-IOS/ERPProject/MTH Accounting/Utilities/APIServices/APIGenerated"
    ;;
  2)
    OUTPUT_DIRECTORY="/Users/coltonh/Documents/GitHub/ERP-IOS/ERPProject/MTH Accounting/Utilities/APIServices/APIGenerated"
    ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

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

echo "Starting the watch-swagger script."

SWAGGER_PATH="$OPENAPI_YAML_PATH"
GENERATE_SCRIPT=$0  # The current script will serve as the generate script

echo "Will watch for changes in $SWAGGER_PATH"
echo "Will execute $GENERATE_SCRIPT when changes are detected."

# Use fswatch to monitor the Swagger YAML file and trigger the generate.sh script upon changes
fswatch -v -o "$SWAGGER_PATH" | xargs -n1 -I{} sh -c "$GENERATE_SCRIPT; echo 'generate.sh has been executed.'"
