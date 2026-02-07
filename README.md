# hello

A simple Java web application using Spring MVC and related technologies.

## Prerequisites

- Java (JDK 21)
- Maven 3.9+
- MySQL 8

## Technologies

- Jakarta (Servlet/JSP)
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- RabbitMQ
- Elasticsearch

## Database

This project uses MySQL. A SQL dump is included at:

- `src/main/resources/db_backup.sql`

Import the dump into a local database named `accounts` with:

```sh
mysql -u <user_name> -p accounts < src/main/resources/db_backup.sql
```

Replace `<user_name>` with your MySQL user. Create the `accounts` database first if it doesn't exist:

```sh
mysql -u <user_name> -p -e "CREATE DATABASE IF NOT EXISTS accounts;"
```

## Build and run

1. Install prerequisites above.
2. Build the project with Maven:

```sh
mvn clean package
```

3. Deploy the generated WAR to Tomcat (or run via your preferred method).

## Notes

- See `src/main/resources/application.properties` for datasource and other configuration.
- For development you may prefer to run an embedded Tomcat or a local server and set the DB credentials accordingly.

---
Small cleanup of README: clarified prerequisites, added build/run steps and fix typos.


