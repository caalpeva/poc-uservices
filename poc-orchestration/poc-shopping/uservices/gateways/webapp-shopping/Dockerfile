FROM openjdk:11

MAINTAINER kalpeva@gmail.com

COPY ./target /tmp
WORKDIR /tmp

EXPOSE 9091
EXPOSE @serverPort@
CMD ["java", "-jar", "@project.artifactId@-@project.version@-fat.@project.packaging@"]
