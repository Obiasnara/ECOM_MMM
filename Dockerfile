# Alpine Linux with OpenJDK JRE
FROM openjdk:17-jdk-alpine

COPY /build/libs/ /app/

# Make port 8080 available to the world outside this container
EXPOSE 8080

# Run the JAR file
CMD ["java", "-jar", "/app/job-0.0.1-SNAPSHOT.jar"]