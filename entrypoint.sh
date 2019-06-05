#!/bin/sh
set -e

wget https://github.com/spring-io/github-release-notes-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-release-notes-generator.jar

java -jar /github-release-notes-generator.jar \
          --releasenotes.github.organization=$ORG_NAME \
          --releasenotes.github.repository=$REPOSITORY \
          --releasenotes.github.username=$GITHUB_USERNAME \
          --releasenotes.github.password=$GITHUB_TOKEN \
          $MILESTONE_ID ./$TARGET_FILE