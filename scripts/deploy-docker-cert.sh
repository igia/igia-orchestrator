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

#
# Deploys private key and public certificates to Docker server


SCRIPT_DIR=$(dirname "$0")
DEFAULT_WORK_DIR=~/docker-cert-authority

read -p "Docker server FQDN: " SERVER_FQDN
read -p "Path where certificates are stored (${DEFAULT_WORK_DIR}): " WORK_DIR

WORK_DIR="${WORK_DIR:-${DEFAULT_WORK_DIR}}"

echo "${SERVER_FQDN}" > docker_tls_inventory
cat >  docker_tls_playbook.yml <<EOL
---
- name: Docker TLS setup 
  hosts: ${SERVER_FQDN}
  gather_facts: yes
  roles:
    - role: docker-tls
EOL

echo "Running Ansible playbook to deploy TLS certificates from ${DEFAULT_WORK_DIR}/${SERVER_FQDN} to Docker engine of ${SERVER_FQDN}..."
echo "NOTE: It will ask for SSH password for Docker server. " 
echo ANSIBLE_ROLES_PATH=${SCRIPT_DIR}/../ansible-playbooks/roles ansible-playbook  docker_tls_playbook.yml -i docker_tls_inventory -k -K -e "mode=deploy" -e "work_dir=${WORK_DIR}"
ANSIBLE_ROLES_PATH=${SCRIPT_DIR}/../ansible-playbooks/roles ansible-playbook  docker_tls_playbook.yml -i docker_tls_inventory -k -K -e "mode=deploy" -e "work_dir=${WORK_DIR}"
