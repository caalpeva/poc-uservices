FROM maven:3.5-alpine AS builder

LABEL version="1.0" maintainer="<kalpeva@gmail.com>"

COPY app-maven /app
WORKDIR /app

RUN mvn package

FROM openjdk:8-alpine

COPY --from=builder /app/target/poc-app-maven-basic-1.0.0.jar /opt/app.jar

CMD java -jar /opt/app.jar
