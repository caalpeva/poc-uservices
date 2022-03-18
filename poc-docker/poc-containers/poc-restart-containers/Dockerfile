FROM centos

LABEL version="1.0" maintainer="<kalpeva@gmail.com>"

ARG EXIT_CODE
ENV EXIT_CODE=${EXIT_CODE:-0}

# copy script
COPY container-lifecycle.sh /container-lifecycle.sh

# grant execution permission
RUN chmod +x /container-lifecycle.sh

# command to execute once the container is instantiated
CMD /container-lifecycle.sh $EXIT_CODE
