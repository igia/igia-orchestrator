# Ansible Role: igia-deployer

Sets up igia platform locally.

## Requirements

This playbook checks the pre-requisites when it runs. Those pre-requisites must be satisfied.

## Structure

Please see [Structure](../../README.md#Structure).

## Role Variables

Ansible variables are listed below, along with default values (see  `defaults/main.yml`).

Following variables can be changed as per your need.

| Variable | Default value | Description |
| ---------|---------------|-------------|
| deploy_dir | ~/igia-apps/ | Path where source code for apps will be downloaded. |
| platform_version | develop | Version of platform to be deployed. |
| selected_optional_components | - igia-keycloak <br> - igia-apigateway <br> - igia-apigateway-postgresql | Optional components to deploy |
| deploy_env | docker | Deployment environment (currently only docker is supported) |

## Dependencies

Does not depend on any other roles in Ansible Galaxy.

## Example Playbook

```yaml
- hosts: localhost
  vars:
    deploy_dir: 'C:\\Users\\igia\\Deployment\\'
  roles:
    - role: igia-deployer
```

## License

To be added

## Author Information

To be added
