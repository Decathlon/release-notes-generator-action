#!/bin/sh
set -e

printf '\033[0;34m
Open sourced by
██████╗ ███████╗ ██████╗ █████╗ ████████╗██╗  ██╗██╗      ██████╗ ███╗   ██╗
██╔══██╗██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║  ██║██║     ██╔═══██╗████╗  ██║
██║  ██║█████╗  ██║     ███████║   ██║   ███████║██║     ██║   ██║██╔██╗ ██║
██║  ██║██╔══╝  ██║     ██╔══██║   ██║   ██╔══██║██║     ██║   ██║██║╚██╗██║
██████╔╝███████╗╚██████╗██║  ██║   ██║   ██║  ██║███████╗╚██████╔╝██║ ╚████║
╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝
\033[0m'

TRIGGER_ACTION="closed"

echo "Getting Action Information"
ACTION=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["action"]' | cut -f2 | sed 's/\"//g')
MILESTONE_NUMBER=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","number"]' | cut -f2)
REPOSITORY_NAME=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["repository","name"]' | cut -f2 | sed 's/\"//g')
OWNER_ID=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["repository","owner","login"]' | cut -f2 | sed 's/\"//g')
GH_USERNAME=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["sender","login"]' | cut -f2 | sed 's/\"//g')


#Check if Milestone exists, which means actions was raised by a milestone operation.
if [[ -z "$MILESTONE_NUMBER" ]]; then
    echo "Milestone number is missing. Was the action raised by a milestone event?"
    exit 1
fi

OUTPUT_FILENAME="release_file.md"
#Check if a filename prefix is provided
if [[ ! -z "$FILENAME_PREFIX" ]]; then
    OUTPUT_FILENAME="$FILENAME_PREFIX$MILESTONE_NUMBER.md"
fi

#Check if we should use milestone title instead
if [[ ! -z "$USE_MILESTONE_TITLE" ]]; then
    MILESTONE_TITLE=$(/JSON.sh < "${GITHUB_EVENT_PATH}" | grep '\["milestone","title"]' | cut -f2 | sed 's/\"//g' | sed 's/ /_/g')
    OUTPUT_FILENAME="$MILESTONE_TITLE.md"
fi

#Output folder configuration
if [ -z "$OUTPUT_FOLDER" ]; then
  echo "OUTPUT_FOLDER ENV is missing, using the default one"
  OUTPUT_FOLDER='.'
else
  mkdir $OUTPUT_FOLDER
fi

if [[ "$ACTION" == "$TRIGGER_ACTION" ]]; then
    echo "Creating release notes for Milestone $MILESTONE_NUMBER into the $OUTPUT_FILENAME file"
    java -jar /github-release-notes-generator.jar \
    --releasenotes.github.organization=${OWNER_ID} \
    --releasenotes.github.repository=${REPOSITORY_NAME} \
    --releasenotes.github.username=${GH_USERNAME} \
    --releasenotes.github.password=${GITHUB_TOKEN} \
    ${MILESTONE_NUMBER} \
    ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
    cat ${OUTPUT_FOLDER}/${OUTPUT_FILENAME}
else
    echo "Release notes generation skipped because action was: $ACTION"
    exit 78
fi
