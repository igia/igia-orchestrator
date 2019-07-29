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
echo This script will run ansible playbook to deploy all igia components that have been build already to local docker server. 
echo 
echo please press any key to start...
read INPUT

SCRIPT_PATH=$(dirname "$0")
ansible-playbook ${SCRIPT_PATH}/../ansible-playbooks/site.yml -e deploy_dir=../..  --tag "deploy"
