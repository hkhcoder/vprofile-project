# Prerequisites
#
- JDK 11 
- Maven 3 
- MySQL 8

# Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- Rabbitmq
- ElasticSearch
# Database
Here,we used Mysql DB 
sql dump file:
- /src/main/resources/db_backup.sql
- db_backup.sql file is a mysql dump file.we have to import this dump to mysql db server
- > mysql -u <user_name> -p accounts < db_backup.sql


---

## Quality Gates

In Sonar Qube, We can create a Quality Gates and add Condition for overall code (Bugs)

Attach the Qualtiy gates to the projects. 

- Sonar qube will send result to the jenkins. We need to add webhook in the Sonarqube

- Add Stages for Quality Gates in the Jenkin Pipeline