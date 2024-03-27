FROM openjdk:11

MAINTAINER kalpeva@gmail.com

COPY ./target /tmp
WORKDIR /tmp

EXPOSE 8080
CMD ["java", "-jar", "@project.artifactId@-@project.version@.@project.packaging@"]
