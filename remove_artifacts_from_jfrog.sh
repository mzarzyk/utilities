#!/bin/bash

# Artifactory details
ARTIFACTORY_URL=""
ARTIFACTORY_USER=""
ARTIFACTORY_PASSWORD=""
BASE_REPO_PATH=""


# Version threshold
VERSION_THRESHOLD="2.7.0.9"

# List of services
services=(

)

      # Loop through each service
      for SERVICE in "${services[@]}"; do
              REPO_PATH="$BASE_REPO_PATH/$SERVICE"

                  # Search for artifacts
                  ARTIFACTS=$(docker run --rm --network host --volume /home/mzarzyck:/home/user artifactory-client jfrog rt s \
                          --url=$ARTIFACTORY_URL \
                          --user=$ARTIFACTORY_USER \
                          --password=$ARTIFACTORY_PASSWORD \
                          --insecure-tls \
                          "$REPO_PATH/*" | jq -r '.[].path')
                      # Initialize an empty set to keep track of processed directories
                      declare -A PROCESSED_DIRECTORIES

                          # Loop through artifacts and delete directories with versions less than the threshold
                          for ARTIFACT in $ARTIFACTS; do
                                  DIRECTORY=$(dirname $ARTIFACT)
                                  VERSION=$(basename $DIRECTORY | awk -F. '{print $NF}')
                                  VERSION_T=$(echo $VERSION_THRESHOLD | awk -F. '{print $NF}')

                                  if [[ $VERSION -lt $VERSION_T && -z "${PROCESSED_DIRECTORIES[$DIRECTORY]}" ]]; then
                                          echo "Deleting directory: $DIRECTORY from service: $SERVICE"
                                          docker run --rm --network host --volume /home/mzarzyck:/home/user artifactory-client jfrog rt delete \
                                                  --url=$ARTIFACTORY_URL \
                                                  --user=$ARTIFACTORY_USER \
                                                  --password=$ARTIFACTORY_PASSWORD \
                                                  --fail-no-op=false \
                                                  --insecure-tls \
                                                  --quiet \
                                                  "$DIRECTORY"
                                    # Mark the directory as processed
            PROCESSED_DIRECTORIES[$DIRECTORY]=1
                                  fi
                          done
                  done
