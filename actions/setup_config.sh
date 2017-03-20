#!/bin/bash
set -e

MISTRAL_PATH=$1
DB_TYPE=$2
DB_NAME=$3
DB_USER_NAME=$4
DB_USER_PASS=$5
API_PORT=$6

CONFIG_PATH=/etc/mistral
MISTRAL_CONFIG=${CONFIG_PATH}/mistral.conf
MISTRAL_LOG_CONFIG=${CONFIG_PATH}/wf_trace_logging.conf
MISTRAL_POLICY_CONFIG=${CONFIG_PATH}/policy.json

# Create config directory
sudo mkdir -p ${CONFIG_PATH}
sudo chown -R ${USER}:${USER} ${CONFIG_PATH}

# Check database type.
if [ "${DB_TYPE}" != "mysql" ] && [ "${DB_TYPE}" != "postgresql" ]; then
    >&2 echo "ERROR: ${DB_TYPE} is an unsupported database type."
    exit 1
fi

# Write mistral configuration file.
echo "Writing mistral configuration to ${MISTRAL_CONFIG}..."

if [ -e "${MISTRAL_CONFIG}" ]; then
  rm -f ${MISTRAL_CONFIG}
fi

touch ${MISTRAL_CONFIG}
cat <<mistral_config >${MISTRAL_CONFIG}
[api]
port=${API_PORT}

[database]
connection=${DB_TYPE}://${DB_USER_NAME}:${DB_USER_PASS}@localhost/${DB_NAME}
max_pool_size=25
max_overflow=50
idle_timeout=30

[pecan]
auth_enable=false
mistral_config

# Write mistral log configuration file.
echo "Writing mistral log configuration to ${MISTRAL_LOG_CONFIG}..."

if [ -e "${MISTRAL_LOG_CONFIG}" ]; then
  rm -f ${MISTRAL_LOG_CONFIG}
fi

cp ${MISTRAL_PATH}/etc/wf_trace_logging.conf.sample ${MISTRAL_LOG_CONFIG}

mkdir -p ${MISTRAL_PATH}/logs
sed -i "s~${MISTRAL_PATH}/logs~/var/log~g" ${MISTRAL_LOG_CONFIG}

# Write mistral policy configuration file.
echo "Writing mistral policy configuration to ${MISTRAL_POLICY_CONFIG}..."

if [ -e "${MISTRAL_POLICY_CONFIG}" ]; then
  rm -f ${MISTRAL_POLICY_CONFIG}
fi

touch ${MISTRAL_POLICY_CONFIG}
cat <<mistral_policy_config >${MISTRAL_POLICY_CONFIG}
{
    "admin_only": "is_admin:True",
    "admin_or_owner":  "is_admin:True or project_id:%(project_id)s",
    "default": "rule:admin_or_owner",

    "action_executions:delete": "rule:admin_or_owner",
    "action_execution:create": "rule:admin_or_owner",
    "action_executions:get": "rule:admin_or_owner",
    "action_executions:list": "rule:admin_or_owner",
    "action_executions:update": "rule:admin_or_owner",

    "actions:create": "rule:admin_or_owner",
    "actions:delete": "rule:admin_or_owner",
    "actions:get": "rule:admin_or_owner",
    "actions:list": "rule:admin_or_owner",
    "actions:update": "rule:admin_or_owner",

    "cron_triggers:create": "rule:admin_or_owner",
    "cron_triggers:delete": "rule:admin_or_owner",
    "cron_triggers:get": "rule:admin_or_owner",
    "cron_triggers:list": "rule:admin_or_owner",

    "environments:create": "rule:admin_or_owner",
    "environments:delete": "rule:admin_or_owner",
    "environments:get": "rule:admin_or_owner",
    "environments:list": "rule:admin_or_owner",
    "environments:update": "rule:admin_or_owner",

    "executions:create": "rule:admin_or_owner",
    "executions:delete": "rule:admin_or_owner",
    "executions:get": "rule:admin_or_owner",
    "executions:list": "rule:admin_or_owner",
    "executions:update": "rule:admin_or_owner",

    "members:create": "rule:admin_or_owner",
    "members:delete": "rule:admin_or_owner",
    "members:get": "rule:admin_or_owner",
    "members:list": "rule:admin_or_owner",
    "members:update": "rule:admin_or_owner",

    "services:list": "rule:admin_or_owner",

    "tasks:get": "rule:admin_or_owner",
    "tasks:list": "rule:admin_or_owner",
    "tasks:update": "rule:admin_or_owner",

    "workbooks:create": "rule:admin_or_owner",
    "workbooks:delete": "rule:admin_or_owner",
    "workbooks:get": "rule:admin_or_owner",
    "workbooks:list": "rule:admin_or_owner",
    "workbooks:update": "rule:admin_or_owner",

    "workflows:create": "rule:admin_or_owner",
    "workflows:delete": "rule:admin_or_owner",
    "workflows:get": "rule:admin_or_owner",
    "workflows:list": "rule:admin_or_owner",
    "workflows:update": "rule:admin_or_owner"
}
mistral_policy_config
