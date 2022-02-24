FROM maven:3.5-alpine AS builder

LABEL version="1.0" maintainer="<kalpeva@gmail.com>"

# copy source code
COPY app-maven /app

# change the working directory
WORKDIR /app

# execute maven tool
RUN mvn package

FROM openjdk:8-alpine

# copy from builder image the jar file to image target
COPY --from=builder /app/target/poc-app-maven-basic-1.0.0.jar /opt/app.jar

CMD java -jar /opt/app.jar
