FROM maven:3.9.9-eclipse-temurin-21-jammy AS build
RUN git clone https://github.com/narsss1234/vprofile-project.git
RUN cd vprofile-project && git checkout aws && mvn install

FROM tomcat:10-jdk21

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build vprofile-project/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]