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

# import os

import requests
# import testinfra.utils.ansible_runner

# testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
#   os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

# def test_hosts_file(host):
#     f = host.file('/etc/hosts')

#     assert f.exists
#     assert f.user == 'root'
#     assert f.group == 'root'


def test_caremanagement_app():
    url = "http://localhost:8091"
    response = requests.request("GET", url)
    assert response.status_code == 200
