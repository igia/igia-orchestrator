#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public License, v.
# 2.0 with a Healthcare Disclaimer.
# A copy of the Mozilla Public License, v. 2.0 with the Healthcare Disclaimer can
# be found under the top level directory, named LICENSE.
# If a copy of the MPL was not distributed with this file, You can obtain one at
# http://mozilla.org/MPL/2.0/.
# If a copy of the Healthcare Disclaimer was not distributed with this file, You
# can obtain one at the project website https://github.com/igia.
#
# Copyright (C) 2018-2019 Persistent Systems, Inc.
#

ANSIBLE_STDOUT_CALLBACK=unixy
echo This script will run ansible playbook to clone, build, and deploy all igia components to local docker server. 
echo 
echo please press any key to start...
read INPUT

SCRIPT_PATH=$(dirname "$0")
STACK_PATH="$SCRIPT_PATH/stack"

## Allow users to skip one or more steps
SKIP_TAGS=""
read -p "Do you need to skip one or more steps (N/y)? " SKIP
case $SKIP in
    y|Y|YES|yes|Yes)
        read -p "Skip fetching code from Git (N/y)? " SKIP_FETCH
        read -p "Skip building apps (N/y)? " SKIP_BUILD
        read -p "Skip deploying apps (N/y)? " SKIP_DEPLOY
        
        SKIP_TAGS="--skip-tags="

        case $SKIP_FETCH in
            y|Y|YES|yes|Yes)
                SKIP_TAGS="${SKIP_TAGS}fetch,"
                ;;
            *)
                unset SKIP_FETCH
                ;;
        esac

        case $SKIP_BUILD in
            y|Y|YES|yes|Yes)
                SKIP_TAGS="${SKIP_TAGS}build,"
                ;;
            *)
                unset SKIP_BUILD
                ;;
        esac

        case $SKIP_DEPLOY in
            y|Y|YES|yes|Yes)
                SKIP_TAGS="${SKIP_TAGS}deploy"
                ;;
            *)
                ;;
        esac
        ;;
    *)
        ;;
    esac

# Allow users to customize the location where codes are to be placed if both fetch and buiild are not skipped
DEFAULT_DEPLOY_DIR="../.."
DEPLOY_DIR_PARAM=""
echo
read -p "Which path to use to place or refer code (Default: ${DEFAULT_DEPLOY_DIR})? " DEPLOY_DIR
DEPLOY_DIR_PARAM="-e deploy_dir=${DEPLOY_DIR:-${DEFAULT_DEPLOY_DIR}}"

# Allow users to specify specific stack if they need to override default values
CUSTOM_VAR_FILE_PARAM=""
SELECT=1
while :; do
    echo
    echo "Deployment stack"
    echo
    echo "1. igia-Platform"
    echo "2. Integration Applications"
    echo "3. i2b2-cdi-ext Applications"
    echo "4. Sample Applications"
    echo "5. SMART-on-FHIR Applications"
    echo "6. Workflow Applications"
    echo "7. Stack with custom config file"
    echo 
    read -p "Choose deployment stack option (Default: 1)? " SELECT
    
    if [[ -z ${SELECT} ]]; then
        SELECT=1
    fi

    case "$SELECT" in
    1)  break ;;
    2)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/data-integration.yml"
        break ;;
    3)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/i2b2-cdi-ext.yml"
        break ;;
    4)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/sample-app.yml"
        break ;;
    5)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/smart-on-fhir.yml"
        break ;;
    6)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/workflow.yml"
        break ;;
    7)  echo 
        read -p "Advaned setting: Any custom config file to override Ansible playbook defaults (Default: "$STACK_PATH/custom.yml")? " CUSTOM_VAR_FILE_PATH
	    if [[ -z ${CUSTOM_VAR_FILE_PATH} ]];then
            CUSTOM_VAR_FILE_PATH="$STACK_PATH/custom.yml"
	    fi
        break ;;
    *)  echo
        echo "The entered stack number is not in the list."
        echo
        ;;
    esac
done

if [[ ! -z ${CUSTOM_VAR_FILE_PATH} ]];then
    if [[ ! -f ${CUSTOM_VAR_FILE_PATH} ]];then
        echo "Custom variable file ${CUSTOM_VAR_FILE_PATH} does not exist."
        exit 1
    fi
    CUSTOM_VAR_FILE_PARAM="-e @${CUSTOM_VAR_FILE_PATH}"
fi

echo
echo "Add-ons"
echo

case $SKIP_DEPLOY in 
	''|n|N|NO|no|No)

	LOGGING_PARAM=""
	read -p "Do you want to enable logstash logging (N/y)? " LOGGING_OPT
	case $LOGGING_OPT in
	    y|Y|YES|yes|Yes)        
	        LOGGING_PARAM="-e logging_logstash_enabled=true"
	        ;;
	
	    *)
	        LOGGING_PARAM="-e logging_logstash_enabled=false"
	        ;;
	esac
	
	TRACING_PARAM=""
	read -p "Do you want to enable zipkin tracing (N/y)? " TRACING_OPT
	case $TRACING_OPT in
	    y|Y|YES|yes|Yes)        
	        TRACING_PARAM="-e tracing_zipkin_enabled=true"
	        ;;
	
	    *)
	        TRACING_PARAM="-e tracing_zipkin_enabled=false"
	        ;;
	esac
    	;;
    *)
    ;;
esac


QA_SELECT=""
QA_SUITE_PARAM=""
QA_SUITE_TYPE_PARAM=""
read -p "Do you want to enable tests execution to verify components against QA suite (N/y)? " QA_SUITE_OPT
case $QA_SUITE_OPT in
    y|Y|YES|yes|Yes)
        QA_SUITE_PARAM="-e platform_components_qa_suite_execution=true"
	# Allow users to specify specific QA suite type if they need to override default values
	QA_SELECT=1
	while :; do
    	    echo
	    echo "QA suite type"
	    echo
	    echo "1. All"
	    echo "2. Karate"
	    echo "3. Protractor"
	    echo "4. Service"
	    echo 
	    read -p "Choose QA suite type option (Default: 1)? " QA_SELECT

            if [[ -z ${QA_SELECT} ]]; then
	        QA_SELECT=1
	    fi

	    case "$QA_SELECT" in
	    1)  QA_SUITE_TYPE_PARAM="-e qa_suite_type=all" 
		break ;;
	    2)  QA_SUITE_TYPE_PARAM="-e qa_suite_type=karate"
	        break ;;
	    3)  QA_SUITE_TYPE_PARAM="-e qa_suite_type=protractor"
	        break ;;
	    4)  QA_SUITE_TYPE_PARAM="-e qa_suite_type=service"
	        break ;;
	    *)  echo
        	echo "The entered QA suite type is not in the list."
	        echo
	        ;;
	    esac
	done
   	;; 
    *)
	QA_SUITE_PARAM="-e platform_components_qa_suite_execution=false"
        ;;
esac

echo
echo "Running the command: ansible-playbook ${SCRIPT_PATH}/../ansible-playbooks/site.yml ${DEPLOY_DIR_PARAM} ${CUSTOM_VAR_FILE_PARAM} ${TRACING_PARAM} ${LOGGING_PARAM} ${QA_SUITE_PARAM} ${QA_SUITE_TYPE_PARAM} ${SKIP_TAGS}"
echo

ansible-playbook ${SCRIPT_PATH}/../ansible-playbooks/site.yml ${DEPLOY_DIR_PARAM} ${CUSTOM_VAR_FILE_PARAM} ${TRACING_PARAM} ${LOGGING_PARAM} ${QA_SUITE_PARAM} ${QA_SUITE_TYPE_PARAM} ${SKIP_TAGS}
