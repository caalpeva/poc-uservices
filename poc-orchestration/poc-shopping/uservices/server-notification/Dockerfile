FROM openjdk:11

MAINTAINER kalpeva@gmail.com

COPY ./target /tmp
WORKDIR /tmp

EXPOSE @serverPort@
CMD ["java", "-jar", "@project.artifactId@-@project.version@.@project.packaging@"]
