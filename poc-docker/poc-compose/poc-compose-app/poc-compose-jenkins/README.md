## Proof of concept about Jenkins and related servers

Before deploying microservices, you need to have ssh keys to securely access remote machines via command line. So, run the following script to generate the public and private shh keys.

```
./poc-compose-jenkins-generate-ssh-keys.sh
```

To deploy the complete environment of microservices, run the following script:

```
./poc-compose-jenkins.sh
```
Next, it is necessary to make some configurations interactively in the machines.

### 1. Configure Gitlab server

Access to http://localhost:80 and create root user with credentials.

#### 1.1 Create repository

  * Create group called _**"poc"**_

  * Create repository called _**"poc-app-maven-simple"**_ within the above group.

  * Create username with password for this repository.

  * Manage repository access for the above username with maintainer permissions.

### 2. Configure Jenkins server

Access to http://localhost:8080 and create main user with credentials (admin/admin).

#### 2.1 Plugin installations

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

#### 2.2 Configure system

  * Configure system E-mail notification

    - SMTP server: smtp.gmail.com
    - SMTP port: 587
    - Use SMTP authentication with <account> and <password> from gmail
    - Use TLS

  * Add SSH sites that projects will want to connect

    - Indicate hostname, port and credentials

#### 2.3 Configure global security

  * Select Role-Based strategy as the authorization method

  * Manage and Assign Roles

    - Create users and roles with permissions.

    - Assign roles to users.

  * Manage credential entries

    - Add credentials called _**"gitlab_credentials"**_ of the type "Username with password" with the same username and password created to access the gitlab repository.

    - Add credentials called _**"jenkins_credentials"**_ of the type "SSH Username with private key" with the username _**"jenkins"**_ and private key contained in the tmp/key file.

  * CSRF Protection

    - Select Stric crumb isuuer
    - Uncheck the session ID
    - Enable script security for Job DSL scripts

#### 2.4 Configure global tools:

  * Maven

    - Add Maven installations

#### 2.5 Configure Jenkins SSH agent:



#### 2.6 Create first Job as _"Seed Job"_

Create a freestyle job called _**"poc-seed-job"**_ to load a DSL script and allow you to generate predefined jobs programmatically.

  * Select _**"Process job DSLs"**_ step.

  * Check _**"Use the provided DSL script"**_ option.

  * Copy the contents of the job-parent.dsl file from jobs directory.

  * Execute "Build now" on parent job.

  * Check that 3 more jobs are created automatically.


Finally run the following script to push application code in Gitlab repository and create hooks with Jenkins jobs.

```
./poc-compose-jenkins-configure-gitlab-hooks.sh
```
