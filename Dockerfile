FROM openjdk:8-alpine
LABEL "maintainer"="Decathlon <developers@decathlon.com>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.8"

COPY *.sh /
RUN chmod +x JSON.sh && \
    wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar
    
COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
