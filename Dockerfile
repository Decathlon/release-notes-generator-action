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
    wget -O github-release-notes-generator.jar https://ucd1f7512113b0c593d98dba7d90.dl.dropboxusercontent.com/cd/0/get/BFU15LNNmRHvWpIeQ31s3JxWsc1L2JnBNmTEcj_6zJbELHm4QcZLQe8dQC5CXtesNJPdUIYT-hu7E6kmEX40As8Sogi4_XkTX3-mnFecFusHfSTLQhbKD9eZPp-NbOldrzw/file?dl=1#

COPY entrypoint.sh /

ENTRYPOINT ["sh", "/entrypoint.sh"]