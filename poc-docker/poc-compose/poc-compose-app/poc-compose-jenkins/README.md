# Installation after booting containers

## Configurar jenkins_home
  ### First create admin user with password.
  ### Create parent job with step "Process job DSLs".
  ### Configure DSL scripts from jobs directory.
  ### Execute "Build now" on parent job.
  ### Add gitlab credentials named "gitlab_credentials".

## Configurar gitlab
  ### First create root user with password.
  ### Create group named "poc"
  ### Create repository named "poc-app-maven-simple"
  ### Create user for repository with same credentials as "gitlab_credentials".
  ### Manage repository access for user with maintainer permissions.
  ### Execute script to push application code and create hook with jenkins.
