#!/bin/bash

# Define the base URLs as constants
BASE_URL=""
TARGET_URL=""

# Function to prompt for input with validation
prompt_for_input() {
  local prompt_message=$1
  local help_message=$2
  local input_variable

  while true; do
    read -p "$prompt_message" input_variable
    if [[ -z "$input_variable" ]]; then
      echo "$help_message"
    else
      echo "$input_variable"
      break
    fi
  done
}

# Prompt for source_catalog_version
source_catalog_version=$(prompt_for_input "Enter source catalog version (e.g., 2.8.0): " "Source catalog version is required.")

# Prompt for target_version
target_version=$(prompt_for_input "Enter target version (e.g., 2.8.0.2): " "Target version is required.")

services=(
)

for service in "${services[@]}"; do
  echo "Processing $service..."
  docker pull $BASE_URL/$source_catalog_version/sdsi/$service:$target_version
  docker tag $BASE_URL/$source_catalog_version/sdsi/$service:$target_version $TARGET_URL/$service:$target_version
  docker push $TARGET_URL/$service:$target_version
done
