# igia-orchestrator

Orchestrator to set up igia stack

## Set up using Ansible playbook

This repository contains Ansible playbook which can be used to set up igia components in local workstation. To use the playbook, Ansible needs to be installed first. Ansible provides a good [installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#control-machine-requirements).

Now, you can run the playbook with following command. `deploy_dir` is the directory where the playbook will download source code of applications and docker-compose files. Details of the roles used in the playbook can be found at roles' documentation page [ansible-playbooks/roles/igia-deployer/README.md](https://github.com/igia/igia-orchestrator/blob/master/ansible-playbooks/roles/igia-deployer/README.md).

```bash
ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook ansible-playbooks/site.yml -e deploy_dir=<dir_path>
```

If everything goes well, you will see something like below and you will able to browse gateway and registry applications.

```bash
PLAY RECAP ************************************************************************************************************************************************************************
localhost                  : ok=6    changed=2    unreachable=0    failed=0
```

> If you want to secure Docker engine with TLS, you can follow the documentation provided for [docker-tls](https://github.com/igia/igia-orchestrator/blob/master/ansible-playbooks/roles/docker-tls/README.md) Ansible role.

## Customizing the set up

Variables defined in `ansible-playbooks/roles/igia-deployer/defaults/main.yml` can be overridden by passing `--extra-vars` (or shorthand `-e`) argument when running Ansible playbook. This argument takes `key=value` form and it can also read variables from YAML or JSON file.

### Example: Deploy the platform from `master` branch of components

```bash
ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook ansible-playbooks/site.yml -e deploy_dir=<dir_path> -e platform_version=master
```

### Example: Deploy selective components

If you want to deploy only components required for care-management, create a YAML file (say, caremanagement.env.yml) with `selected_optional_components` specified.

```YAML
selected_optional_components:
  - keycloak
  - apigtw
  - apigtw-postgresql
  - camunda
  - camunda-postgresql
  - caremanagement
  - caremanagement-postgresql
```

Then, pass this file's path as `extra-vars` argument.

```bash
ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook ansible-playbooks/site.yml -e deploy_dir=<dir_path> -e '@local.env.yml'
```

### Example: Enabling logstash logging and zipkin tracing

You can set up infrastructure required for logging and tracing by overriding `tracing_zipkin_enabled` and `logging_logstash_enabled` variables.

```bash
 ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook ansible-playbooks/site.yml -e deploy_dir=<dir_path> \
    -e tracing_zipkin_enabled=true -e logging_logstash_enabled=true
```

## Pre-configured Stacks

igia Orchestrator provides following pre-configured stacks:

```bash
1. igia-Platform                    -   Deploy all igia platform components
2. Integration Applications         -   Deploy Integration components
3. i2b2-cdi-ext Applications        -   Deploy i2b2 clinical data infrastructure components
4. Sample Applications              -   Deploy Sample application components
5. SMART-on-FHIR Applications       -   Deploy Smart on FHIR application components
6. Workflow Applications            -   Deploy Workflow components
```

### Add new stack configuration

1. Create a YAML and place under `cli/stack` (say, workflow.yml) with `selected_optional_components` specified.

    ```bash
    ## Optional components which are selected for workflow stack deployment
    selected_optional_components:
    - keycloak
    - apigtw
    - apigtw-postgresql
    - camunda
    - camunda-postgresql
    - caremanagement
    - caremanagement-postgresql
    - portainer
    ```

2. Add a new label in the `start.sh` to briefly describe custom stack. This label will be visible during stack selection.

    ```bash
    echo "6. Workflow Applications"
    ```

3. Add a case in `start.sh` in sequence. Sequence number should match the label sequence specified in the above step.

    ```bash
    6)  CUSTOM_VAR_FILE_PATH="${STACK_PATH}/workflow.yml"
            break ;;
    ```

### Launch

You can choose pre-configured stacks or create your own. The `cli/start.sh` launches the pre-configured or the custom stacks.

```bash
This script will run ansible playbook to clone, build, and deploy all igia components to local docker server.

please press any key to start...

Do you need to skip one or more steps (N/y)? 

Which path to use to place code (Default: ../..)? 

Deployment stack

1. igia-Platform
2. Integration Applications
3. i2b2-cdi-ext Applications
4. Sample Applications
5. SMART-on-FHIR Applications
6. Workflow Applications
7. Stack with custom config file

Choose deployment stack option (Default: 1)? 5

Add-ons

Do you want to enable logstash logging (N/y)? y
Do you want to enable zipkin tracing (N/y)? 
Do you want to enable tests execution to verify components against QA suite (N/y)? y

QA suite type

1. All
2. Karate
3. Protractor
4. Service

Choose QA suite type option (Default: 1)? 1

Running the command: ansible-playbook ./../ansible-playbooks/site.yml -e deploy_dir=../.. -e @./stack/smart-on-fhir.yml -e tracing_zipkin_enabled=false -e logging_logstash_enabled=true -e platform_components_qa_suite_execution=true -e qa_suite_type=all 

```

You can refer `cli/stack/custom.yml` to create custom deployment stack. By default, it contains all platform components.

### Common ports

igia Orchestrator exposes deployed services to the ports listed below. If the port is already in use, you can override them setting corresponding environment variable.

| Port | Description  | Environment Variable to override |
|-----|-------|-------|
|5601|Jhipster console for log monitoring|JHIPSTER_CONSOLE_PORT|
|7000|Portainer for Docker container management|PORTAINER_PORT|
|8052|Integration gateway UI|INTEGRATION_APP_PORT|
|8054|Sample Application UI|SAMPLE_APP_PORT|
|8088|API gateway UI|APIGTW_PORT|
|8091|Caremanagement UI|CAREMANAGEMENT_PORT|
|8096|Patient data manager|PATENT_DATA_MANAGER_PORT|
|8761|Jhipster registry|JHIPSTER_REGISTRY_PORT|
|8888|Nginx which hosts static landing page|NGINX_PORT|
|9080|Keycloak admin interface|KEYCLOAK_PORT|
|9081|SMART launch application|SMART_LAUNCH_APP_PORT|
|9085|Camunda UI|CAMUNDA_PORT|
|9411|Zipkin UI|ZIPKIN_PORT|
|12000-12100|Port range for Integration worker|INTEGRATION_WORKER_PORT_RANGE|
|8086|i2b2 web application|I2B2_WEB_HTTP_PORT|

## Adding a new component to igia-orchestrator

If you want to have your component to be deployed with igia-orchestrator, you will need to do following:

1. Create a new docker-compose file inside `docker-compose/local-dev` directory with convention `<appname>.yml`. Please see [Consideration with docker-compose file](#consideration-with-docker-compose-file).

2. If your application is Spring based application, you may want to add `<appname>-<profile>.yml` file inside `docker-compose\local-dev\central-server-config` folder for any default application configuration for your application. igia central config server (i.e. jhipster-registry) loads application configuration from this folder when igia is deployed locally.

3. Add an entry for your component under _apps_ section in `ansible-playbooks/roles/igia-deployer/vars/main.yml`. Example:

    ```yaml
    - repo_url: https://github.com/igia/igia-keycloak.git # SCM Url
        repo_ref: master                                                # Unless there is any good reason, always use "{{ platform_version }}"
        app_name: keycloak                                              # this name must match the suffix used in docker-compose file. See #1 above.
        build_command: ./mvnw package -Pprod -DskipTests=true dockerfile:build  # Command which builds Docker image from this project.
    ```

4. Also, it is a good idea to update commented block for `configuration` ansible variable in `ansible-playbooks/roles/igia-deployer/vars/main.yml` if you are using it in the playbook and you expect that variable to be overridden based on deployment scenarios. For example, when existing keycloak is used, the user should set configuration.keycloak.keycloak-url to the URL of existing KeyCloak server. Otherwise, this can be left unset.

    ```yaml
    ## Component specific configuration
    # configuration:
    #    ....
    #    keycloak:
    #        keycloak-url: https://<ext_keycloak>
    #        ...
    ```

5. Specify mandatory platform components under `mandatory_components` option in the `ansible-playbooks/roles/igia-deployer/vars/main.yml` file.

6. Specify optional platform components under `selected_optional_components` option in the `ansible-playbooks/roles/igia-deployer/defaults/main.yml` file. If this component is part of a pre-configured or custom stack, then, it should also be added under `selected_optional_components` option in the corresponding  `cli/stack/<stack>.yml` file.

## Consideration with docker-compose file

* The name of the file should follow the convention `docker-compose-<appname>.yml`.
* Compose file version should match with other docker-compose files in the same directory. Currently, we are using Compose file version 3.2.
* If there is any configuration which can differ across environments, such configuration should be specified through environment variables and default values. For example, instead of hard coding the password string, the use of a separate environment variable (which would later be interpolated) helps users to specify non-default password for KeyCloak administrator user without changing any docker-compose files.

    ``` yaml
    version: '3.2'
    services:
        keycloak:
            .....
            environment:
                - KEYCLOAK_PASSWORD=${KEYCLOAK_PASSWORD:-admin}
            ...
    ```

## License Header

New files should contain appropriate license header. You can use the following command to add license header:

```bash
./mvnw license:format
```

## License and Copyright

MPL 2.0 w/ HD   
See [LICENSE](LICENSE) file.    
See [HEALTHCARE DISCLAIMER](HD.md) file.   
© [Persistent Systems, Inc.](https://www.persistent.com)
