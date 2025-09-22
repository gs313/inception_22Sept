#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the paths for your bind mounts
MARIADB_DATA_PATH="/home/scharuka/data/mariadb"
WORDPRESS_DATA_PATH="/home/scharuka/data/wordpress"

# Create the directories if they don't already exist
echo "Checking for and creating data directories..."
mkdir -p "${MARIADB_DATA_PATH}"
mkdir -p "${WORDPRESS_DATA_PATH}"

echo "Setup complete. You can now run 'docker-compose up'."
