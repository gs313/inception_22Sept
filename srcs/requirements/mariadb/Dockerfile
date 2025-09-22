FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    gettext \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /docker-entrypoint-initdb.d \
    && mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

COPY ./tools/create_db.sh /create_db.sh
RUN chmod +x /create_db.sh
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld

EXPOSE 3306
# PORT 3306:3306

ENTRYPOINT ["/create_db.sh"]

# CMD ["yes"]


# CMD ["mysqld_safe"]
