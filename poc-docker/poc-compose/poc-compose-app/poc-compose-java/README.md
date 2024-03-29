# poc-remote-debug

This is a proof of concept on using remote debugging in Java.
Follow the following steps:

- Build the application distribution:
```
mvn clean package 
```
- Run application and enable debug mode from the command line:
 ```
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 -jar target/poc-remote-debug-1.0-SNAPSHOT-jar-with-dependencies.jar
```
- Add remote JVM debugging configuration from IDE:
```
host: localhost 
port: 5005
```
- Debug project, interact with the application and check that debug mode has been connected correctly.