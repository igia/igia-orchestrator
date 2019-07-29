# Ansible Role: docker-tls

Secure Docker engine with TLS based on [this article from Docker](https://docs.docker.com/engine/security/https/#create-a-ca-server-and-client-keys-with-openssl).

The role can be run to perform one of following two actions:

1. Generating TLS certificates and keys for Docker engine and client

2. Deploying TLS certificates and key to Docker server

## Requirements

This playbook checks the pre-requisites when it runs. Those pre-requisites must be satisfied.

## Structure

Please see [Structure](../../README.md#Structure).

## Role Variables

Ansible variables are listed below, along with default values (see  `defaults/main.yml`).

Following variables can be changed as per your need.

| Variable | Default value | Description |
| ---------|---------------|-------------|
| mode | generate | Play mode (`generate` for generating certs or `deploy` mode for deploying certs to Docker server) |
| work_dir | ~/docker-cert-authority | Directory in which a folder with the name server_fqdn is created and all generated keys and certs will be placed inside this new folder. |
| ca_key_passphrase | changeit | Passphrase to be used for CA private key |

## Dependencies

Does not depend on any other roles in Ansible Galaxy.

## Example

You can use example scripts for [generating the self-signed certificate](../scripts/generate-docker-cert.sh) and for [deploying the certificate](../scripts/deploy-docker-cert.sh).

Or, you can follow the steps below.

Create the playbook

```yaml
- hosts: docker-server1
  roles:
    -   role: docker-tls
```

Create the inventory file

```yaml
[docker-server1]
docker-server1.mydomain
```

Run the playbook (probably, in the machine which you want to consider as a CA)

```bash
# To generate certs
# This generates private key and public certificates for CA, Docker server and Docker client in <path_to_place_certs>\<server_fqdn> folder.
ANSIBLE_ROLES_PATH=<path_to_roles_folder> ansible-playbook <playbook_path> -i <inventory_path> -k -K -e "ca_key_passphrase=<desired_password_for_CA_private_key>" -e "mode=generate" -e "work_dir=<path_to_place_certs>"

# To deploy certs
ANSIBLE_ROLES_PATH=<path_to_roles_folder> ansible-playbook <playbook_path> -i <inventory_path> -k -K -e "mode=deploy"
```

## License

To be added

## Author Information

To be added