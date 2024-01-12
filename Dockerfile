FROM openjdk:21
EXPOSE 8080
ADD target/vprofile-v2.war vprofile-v2.war
ENTRYPOINT [ "java", "-jar","/vprofile-v2.war" ]
