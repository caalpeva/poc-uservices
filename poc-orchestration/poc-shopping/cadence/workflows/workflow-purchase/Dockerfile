FROM openjdk:11

MAINTAINER kalpeva@gmail.com

COPY ./target /tmp
WORKDIR /tmp

EXPOSE 8888
CMD ["java", "-jar", "@project.artifactId@-@project.version@-fat.@project.packaging@"]
