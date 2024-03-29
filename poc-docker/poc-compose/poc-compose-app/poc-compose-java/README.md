# poc-remote-debug

This is a proof of concept on using remote debugging in Java from Docker.

Run the following poc-compose-java.sh script and monitor the creation of the docker image, the use of docker-compose and the iteration with remote debugging from the IDE.

>**Note:**
When the Docker image is built, debug mode is enabled.\
It is important to understand docker port mapping to allow connection to the container's debug port.
