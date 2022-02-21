FROM maven:3.5-alpine AS builder

COPY app-maven-basic /app
WORKDIR /app

RUN mvn package

FROM openjdk:8-alpine

COPY --from=builder /app/target/poc-app-maven-basic-1.0.0.jar /opt/app.jar

CMD java -jar /opt/app.jar
