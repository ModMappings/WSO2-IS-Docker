# set base Docker image to AdoptOpenJDK Alpine Docker image
FROM adoptopenjdk/openjdk11:jdk-11.0.9_11-alpine

# set Docker image build arguments
# build arguments for WSO2 product installation
ARG WSO2_SERVER_NAME=wso2is
ARG WSO2_SERVER_VERSION=5.11.0
ARG WSO2_SERVER_REPOSITORY=product-is
ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
ARG WSO2_SERVER_HOME=/${WSO2_SERVER}
ARG WSO2_SERVER_DIST_URL=https://github.com/wso2/${WSO2_SERVER_REPOSITORY}/releases/download/v${WSO2_SERVER_VERSION}/${WSO2_SERVER}.zip
# build arguments for external artifacts
ARG DNS_JAVA_VERSION=2.1.8
ARG K8S_MEMBERSHIP_SCHEME_VERSION=1.0.7
# build argument for MOTD
ARG MOTD='printf "\n\
 Welcome to WSO2 Docker Resources \n\
 --------------------------------- \n\
 This Docker container comprises of a WSO2 product, running with its latest release \n\
 which is under the Apache License, Version 2.0. \n\
 Read more about Apache License, Version 2.0 here @ http://www.apache.org/licenses/LICENSE-2.0.\n\
 --------------------------------- \n\
 This special image is maintained by ModMappings and adds a set of adaptations: \n\
   -> Improved volume management \n\
   -> Better configurability by exposing additional configuration files. \n\
   -> Automatically build when a new release is published. \n\
   -> Removed K8S Membership detector for a smaller image. \n\
   -> Expose normal in memory database . \n\
 --------------------------------- \n\"'

# Mark the current image as maintained by us, and where the source comes from.
LABEL maintainer="ModMappings" \
      com.wso2.docker.source="https://github.com/wso2/docker-is/releases/tag/${WSO2_SERVER_VERSION}"

# Update the environment.
ENV ENV="/root/.ashrc"

# create the MOTD login message
RUN echo ${MOTD} > "${ENV}"

# install required packages
RUN apk add --no-cache netcat-openbsd
RUN apk add --no-cache rsync

# add the WSO2 product distribution to user's home directory
RUN \
    wget -O ${WSO2_SERVER}.zip "${WSO2_SERVER_DIST_URL}" \
    && unzip -d / ${WSO2_SERVER}.zip \
    && rm -f ${WSO2_SERVER}.zip \
    && mkdir /wso2-is-db-base \
    && cp -r ${WSO2_SERVER_HOME}/repository/database/* /wso2-is-db-base/

# copy init script to user home
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
RUN dos2unix /docker-entrypoint.sh

# set environment variables
ENV WORKING_DIRECTORY=/ \
    WSO2_SERVER_HOME=${WSO2_SERVER_HOME}

# expose ports
EXPOSE 4000 9763 9443

# expose config mounting point, artifact mounting point and h2 database mount point for persistence.
VOLUME /wso2-config-volume
VOLUME /wso2-artifact-volume
VOLUME ${WSO2_SERVER_HOME}/repository/database

# initiate container and start WSO2 Carbon server
ENTRYPOINT /docker-entrypoint.sh
