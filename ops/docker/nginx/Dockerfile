# Use official nginx alpine image
FROM nginx:alpine3.22

# Copy simple nginx configuration for Invoice Ninja FastCGI proxy
COPY ops/docker/nginx/config/default.conf /etc/nginx/conf.d/default.conf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Use nginx default user and configuration
EXPOSE 80
