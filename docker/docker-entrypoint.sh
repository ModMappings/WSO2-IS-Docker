#!/usr/bin/env bash

set -e

# volume mounts
config_volume=/wso2-config-volume
artifact_volume=/wso2-artifact-volume
database_template=/wso2-is-db-base

# check if the WSO2 non-root user home exists
test ! -d ${WORKING_DIRECTORY} && echo "WSO2 Docker non-root user home does not exist" && exit 1

# check if the WSO2 product home exists
test ! -d ${WSO2_SERVER_HOME} && echo "WSO2 Docker product home does not exist" && exit 1

# check if the config-volume exists
test ! -d ${WSO2_SERVER_HOME} && mkdir -p ${config_volume}

# copy all configuration files if they do not exist into the config volume so that they can be configured properly for the next start.
rsync -a --prune-empty-dirs --ignore-existing --include '*/' --include '*.xml' --exclude '*' ${WSO2_SERVER_HOME}/ ${config_volume}/
rsync -a --prune-empty-dirs --ignore-existing --include '*/' --include '*.toml' --exclude '*' ${WSO2_SERVER_HOME}/ ${config_volume}/

# copy all db files if they do not exist into the db volume so that they can be configured properly for the next start.
rsync -a --prune-empty-dirs --ignore-existing --include '*/' ${database_template}/ ${WSO2_SERVER_HOME}/repository/database/

# copy any configuration changes mounted to config_volume
if [ -z "$(ls -A ${config_volume})" ]; then
   echo "Configuration is empty, not copying files."
else
   echo "Copying configuration files."
   cp -RL ${config_volume}/* ${WSO2_SERVER_HOME}/
fi

# copy any artifact changes mounted to artifact_volume
if [ -z "$(ls -A ${artifact_volume})" ]; then
   echo "Artifacts is empty, not copying files."
else
   echo "Copying artifact files."
   cp -RL ${artifact_volume}/* ${WSO2_SERVER_HOME}/
fi

cat ${WSO2_SERVER_HOME}/repository/conf/carbon.xml

# start WSO2 Carbon server
sh ${WSO2_SERVER_HOME}/bin/wso2server.sh "$@"
