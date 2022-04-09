# Installation after booting containers

## Configure Jenkins server
  ### First create main user with creadentials (admin/admin).
  ### Install Role-based Authorization Strategy Plugin to assign roles.
  ### Install Crumb Issuer Plugin to enable CSRF protection successfully.
  ### Add credentials for Gitlab named "gitlab_credentials".
  ### Create parent job with step "Process job DSLs".
  ### Configure DSL scripts from jobs directory.
  ### Execute "Build now" on parent job.
  ### Add gitlab credentials named "gitlab_credentials".

## Configure Gitlab server
  ### First create root user with credentials.
  ### Create group named "poc"
  ### Create repository named "poc-app-maven-simple"
  ### Create user for repository with same credentials as "gitlab_credentials".
  ### Manage repository access for user with maintainer permissions.
  ### Execute script to push application code and create hook with jenkins.

## Configure SSH agent
  ### Create a Jenkins SSH credentials
