FROM openjdk:8-alpine
LABEL "maintainer"="Decathlon <developers@decathlon.com>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v1.0.0" \
    ORG_NAME=${ORG_NAME:-"myorg"} \
    REPOSITORY=${REPOSITORY:-"myrepo"} \
    MILESTONE_ID=${MILESTONE_ID:-"1"} \
    TARGET_FILE=${TARGET_FILE:-"release_notes.md"}

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]