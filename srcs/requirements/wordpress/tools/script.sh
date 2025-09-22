#!/bin/bash
set -eo pipefail


# Ensure all secrets files exist before trying to read them
if [ ! -f /run/secrets/db_user_password ] || \
   [ ! -f /run/secrets/WP_ADMIN_PASSWORD ] || \
   [ ! -f /run/secrets/WP_USER_PASSWORD ]; then
  echo "Error: One or more secret files not found."
  exit 1
fi

# Use process substitution to read secrets securely
DB_PASSWORD=$(cat /run/secrets/db_user_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/WP_ADMIN_PASSWORD)
WP_USER_PASSWORD=$(cat /run/secrets/WP_USER_PASSWORD)

# Wait for MariaDB to be ready using a more robust check
echo "Waiting for MariaDB to be ready..."
until mysql -h "${DB_HOST}" -u "${MARIADB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1" &>/dev/null; do
    echo "MariaDB is not ready yet. Waiting..."
    sleep 3
done
echo "MariaDB is ready!"

# Configure and install WordPress only if wp-config.php doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp core config --dbhost="${DB_HOST}" \
                   --dbname="${MARIADB_DATABASE}" \
                   --dbuser="${MARIADB_USER}" \
                   --dbpass="${DB_PASSWORD}" \
                   --allow-root

    echo "Installing WordPress..."
    wp core install --title="${WP_TITLE}" \
                    --admin_user="${WP_ADMIN}" \
                    --admin_password="${WP_ADMIN_PASSWORD}" \
                    --admin_email="${WP_EMAIL}" \
                    --url="${WP_URL}" \
                    --allow-root
    echo "WordPress configuration completed!"
fi

# Create additional user if it doesn't exist
if ! wp user get "${WP_USER}" --allow-root &>/dev/null; then
    echo "Creating user ${WP_USER}..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
                   --role=author \
                   --user_pass="${WP_USER_PASSWORD}" \
                   --allow-root
fi

# Set more secure permissions
chown -R www-data:www-data /var/www/html/
find /var/www/html -type d -exec chmod 755 {} +
find /var/www/html -type f -exec chmod 644 {} +

# Create uploads directory with proper permissions if it doesn't exist
mkdir -p /var/www/html/wp-content/uploads
chmod 755 /var/www/html/wp-content/uploads
chown www-data:www-data /var/www/html/wp-content/uploads

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground
exec php-fpm8.2 -F
