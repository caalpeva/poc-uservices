# Proof of concept about Jenkins and related servers

Before deploying microservices, you need to have ssh keys to securely access remote machines via command line. So, run the following script to generate the public and private shh keys.

```
./poc-compose-jenkins-generate-ssh-keys.sh
```

To deploy the complete environment of microservices, run the following script:

```
./poc-compose-jenkins.sh
```
Next, it is necessary to make some configurations interactively in the machines.

## 1. Configure Gitlab

Access to http://localhost:80 and create root user with credentials.

### 1.1 Create repository

  * Create group called _**"poc"**_

  * Create repository called _**"poc-app-maven-simple"**_ within the above group.

  * Create username with password for this repository.

  * Manage repository access for the above user by granting maintainer permissions.

## 2. Configure Jenkins

Access to http://localhost:8080 and create main user with credentials (admin/admin).

### 2.1 Plugin installations

Install the plugins suggested in the initial process and also install the following plugins:

| Plugin | Description |
| ------ | ----------- |
| Crumb Issuer    | A strict crumb issuer with capacities such session ID check, time-dependent validity or protection against BREACH. |
| HTML Publisher     | This plugin publishes HTML reports. |
| Job DSL | This plugin allows Jobs and Views to be defined via DSL. |
| Mailer    | This plugin allows you to configure email notifications for build results. |
| Maven Integration   | This plugin provides a deep integration of Jenkins and Maven. |
| Role-Based Authorization Strategy | Enables user authorization using a Role-Based strategy. |
| SSH    | This plugin executes shell commands remotely using SSH protocol. |
| SSH Agent   | This plugin allows you to provide SSH credentials to builds via a ssh-agent in Jenkins |

### 2.2 Configure global security

Secure Jenkins; define who is allowed to access/use the system and configure credentials.

  * Select Role-Based strategy as the authorization method

  * Manage and Assign Roles

    - Create users and roles with permissions.

    - Assign roles to users.

  * Manage credentials

    - Add credentials called _**"gitlab_credentials"**_ of the type "Username with password" with the same username and password created to access the gitlab repository.

    - Add credentials called _**"jenkins_credentials"**_ of the type "SSH Username with private key" with the username _**"jenkins"**_ and private key contained in the tmp/key file.

  * CSRF Protection

    - Select Stric crumb isuuer

    - Uncheck the session ID

    - Enable script security for Job DSL scripts

### 2.3 Configure system

Configure global settings and paths.

  * Configure system E-mail notification

    - SMTP server: _**smtp.gmail.com**_

    - SMTP port: _**587**_

    - Use SMTP authentication with username and password from gmail

    - Use TLS

  * Add SSH sites that projects will want to connect

    - Indicate hostname _**"poc_server_ssh"**_, port _**"22"**__ and credentials _**"jenkins_credentials"**_

    - Check the connection is successful.


### 2.4 Configure global tools

Configure tools, their locations and automatic installers.

  * Maven

    - Add Maven installations

### 2.5 Manage nodes

Add, remove, control and monitor the various nodes that Jenkins runs jobs on.

  * Add new node with the following data:
    - Name: _**agent1**_

    - Remote root directory: _**/home/jenkins_home**_

    - Usage: Select _**"Only build jobs with label expressions matching this node"**_

    - Launch method: Select _**"Launch agents via SSH"**_

    - Host: _**poc_server_jenkins_agent_ssh**__

    - Credentials: Select _**"jenkins_credentials"**_

    - Host key verification strategy: Select _**"Manually trusted key verification strategy"**_

    - Check the connection is successful.

### 2.6 Create first Job as _"Seed Job"_

Create a freestyle job to load a DSL script and programmatically generate predefined jobs.

  * Select _**"Process job DSLs"**_ step.

  * Check _**"Use the provided DSL script"**_ option.

  * Copy the contents of the _**"job-parent.dsl"**_ file from jobs directory.

  * Execute _**"Build now"**_ on parent job.

  * Check that 3 more jobs are created automatically.


Finally run the following script to push application code in Gitlab repository and create hooks with Jenkins jobs.

```
./poc-compose-jenkins-configure-gitlab-hooks.sh
```
