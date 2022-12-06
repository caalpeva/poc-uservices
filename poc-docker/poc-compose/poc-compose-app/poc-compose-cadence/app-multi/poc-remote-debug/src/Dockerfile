FROM openjdk:8
COPY . /tmp
WORKDIR /tmp
EXPOSE 5005
ENV JAVA_TOOL_OPTIONS -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005
CMD ["java", "-jar", "poc-remote-debug-1.0-SNAPSHOT.jar"]
#CMD ["java", "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005", "-jar", "poc-remote-debug-1.0-SNAPSHOT.jar"]