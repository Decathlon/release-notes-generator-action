FROM openjdk:8-alpine
LABEL "maintainer"="Decathlon <developers@decathlon.com>"
LABEL "com.github.actions.name"="release-notes-generator-action"
LABEL "com.github.actions.description"="Create a release notes of milestone"
LABEL "com.github.actions.icon"="pocket"
LABEL "com.github.actions.color"="blue"

ENV RELEASE_NOTE_GENERATOR_VERSION="v0.0.5"

COPY *.sh /
RUN chmod +x JSON.sh && \
    #wget -O github-release-notes-generator.jar https://github.com/spring-io/github-changelog-generator/releases/download/${RELEASE_NOTE_GENERATOR_VERSION}/github-changelog-generator.jar
    wget -O github-release-notes-generator.jar https://www.dropbox.com/s/uwqa2bgkp0qsyna/github-changelog-generator.jar?dl=1 

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]
