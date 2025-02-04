FROM mysql:8.0.33
LABEL "Project"="vprofile"
LABEL "Author"="Prabhat"

ENV MYSQL_ROOT_PASSWORD="vprodbpass"
ENV MYSQL_DATABASE="accounts"

ADD db_backup.sql docker-endpoint-initdb.d/db_backup.sql