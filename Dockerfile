FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# web.xml declares Servlet 2.5 (javax.servlet, pre-Jakarta) — Tomcat 9 is the
# newest version that still speaks that namespace; Tomcat 10+ is Jakarta-only
# and won't load this webapp regardless of the pom's Spring 6 dependencies.
FROM tomcat:9-jdk17-temurin
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
