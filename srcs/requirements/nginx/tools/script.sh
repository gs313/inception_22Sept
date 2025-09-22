#!/bin/bash

# Generate SSL certificate if it doesn't exist
if [ ! -f /etc/ssl/private/nginx.crt ]; then
    echo "Generating SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/private/nginx.crt \
        -subj "/C=TH/ST=Bangkok/L=Bangkok/O=42School/CN=scharuka.42.fr"
    echo "SSL certificate generated!"
fi

echo "Starting NGINX..."
# Start nginx in foreground
nginx -g "daemon off;"
