# Ansible playbooks for igia

Ansible playbooks and roles for setting up igia.

> Role-specific detailed documentation are available inside roles/<role_name> folder.

## Structure

Ansible playbooks and roles are strcutured as below:

```bash
site.yml                  # master playbook
localhost.yml             # playbook for deploying to localhost
roles/
    <role_name>/
        tasks/      # Contains the tasks which do the actual work.
        handlers/   # Contains handlers, which, when notified, trigger actions.
        defaults/   # Default values for role specific variables. These are supposed to get overridden.
        vars/       # Role specific variables, which are not supposed to get overridden.
        templates/  # jinja2 templated files used in the role.
        files/      # Static files used in the role.
        meta/       # Meta information for the role.
        tests/      # Tests for the role
```

## Ansible roles

Following Ansible roles are included in this repo:
| Role name | Purpose |
|-----------|---------|
| [docker-tls](roles/docker-tls/README.md)| Role to secure Docker engine with TLS. Not used for local deployment, but might be helpful for other environments |
| [igia-deployer](roles/igia-deployer/README.md) | Role to deploy igia components |

## Testing Orchestrator

igia-Orchestrator (and more specifically igia-deployer role) can be tested with Ansible molecule. For this, you will need to install:

* [Molecule](https://molecule.readthedocs.io/en/latest/)
* [Vagrant](https://www.vagrantup.com/downloads.html)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Python-vagrant package  (Run `sudo pip install python-vagrant`)

Then, run following command:

```bash
cd anisble-playbooks/roles/igia-deployer
molecule test
```
