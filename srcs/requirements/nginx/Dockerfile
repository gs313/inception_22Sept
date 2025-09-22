FROM debian:bookworm

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration and script
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

# Create SSL directory
RUN mkdir -p /etc/ssl/private

# Expose port 443
EXPOSE 443

# Start nginx
ENTRYPOINT ["/usr/local/bin/script.sh"]
