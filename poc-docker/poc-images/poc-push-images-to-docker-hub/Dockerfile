FROM ubuntu:18.04

LABEL version="1.0" maintainer="<kalpeva@gmail.com>"

# install tree
RUN apt-get update && \
    apt-get install -y tree

# install curl
RUN apt-get update && \
    apt-get install -y curl

# install mysql client
RUN apt-get update && \
    apt-get install mysql-client -y

# install network utils
# RUN apt-get update && \
#    apt-get install -y net-tools && \
#    apt-get install -y iputils-ping
