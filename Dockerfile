FROM openjdk:11-jdk-slim

EXPOSE 8080

ADD target/spring-boot-with-metrics-1.0.0-SNAPSHOT.jar. spring-boot.jar

ENTRYPOINT ["java" ,"-jar","spring-boot.jar"]
