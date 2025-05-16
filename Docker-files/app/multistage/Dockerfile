# Build stage
FROM maven:3.9.9-eclipse-temurin-21-jammy AS BUILD_IMAGE

# Clone the repository
RUN git clone https://github.com/hkhcoder/vprofile-project.git

# Set working directory
WORKDIR /vprofile-project

# Checkout the correct branch and build the project
RUN git checkout docker && mvn clean install

# Final stage
FROM tomcat:10-jdk21

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR file from build stage
COPY --from=BUILD_IMAGE /vprofile-project/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

# Expose port and start tomcat
EXPOSE 8080
CMD ["catalina.sh", "run"]
