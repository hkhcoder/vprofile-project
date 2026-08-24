FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# web.xml declares Servlet 2.5 (javax.servlet), but pom.xml actually pulls in
# Spring 6 / Boot 3.1, which is Jakarta-only (jakarta.servlet.*) — the real
# classes on the classpath, not the stale web.xml schema attribute, determine
# the runtime requirement. Tomcat 9 has no jakarta.servlet.* at all, which
# throws NoClassDefFoundError on Spring's ContextLoaderListener. Tomcat 10+
# ships jakarta.servlet.* and deploys an old-schema web.xml fine regardless.
FROM tomcat:10.1-jdk17-temurin
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
