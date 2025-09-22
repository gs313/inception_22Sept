#!/bin/bash
set -e

# Read passwords and other variables from secrets
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MARIADB_PASSWORD=$(cat /run/secrets/db_user_password)
MARIADB_DATABASE=${MARIADB_DATABASE:-wordpress}
MARIADB_USER=${MARIADB_USER:-wpuser}

# Export variables for `envsubst`
export MARIADB_ROOT_PASSWORD
export MARIADB_PASSWORD
export MARIADB_DATABASE
export MARIADB_USER


# Initialize database if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# mysqld_safe &

# Start MariaDB in the background as the `mysql` user
echo "Starting MariaDB in the background..."
su mysql -s /bin/bash -c "mysqld --skip-networking" &
pid="$!"

# Wait for MariaDB to start
sleep 5

# Configure the database
echo "Configuring database..."
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOSQL


# Run the initialization SQL script
envsubst < /docker-entrypoint-initdb.d/init.sql | mysql -u root -p"${MARIADB_ROOT_PASSWORD}"
echo "eiei"
echo $MARIADB_ROOT_PASSWORD
# Stop the background MariaDB process
kill "$pid"
# wait "$pid"
# mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# mysql

# mysqladmin shutdown -u root -p"${MARIADB_ROOT_PASSWORD}"
mysqld --bind-address=0.0.0.0 --user=mysql
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql

# mysql --bind-address=0.0.0.0 --user=wpuser -u root -p"${MARIADB_ROOT_PASSWORD}"

# Start MariaDB in the foreground as the `mysql` user
# echo "Starting MariaDB..."
# exec su mysql -s /bin/bash -c "mysqld"
# exec mysqld_safe

