# Use official nginx alpine image
FROM nginx:alpine3.22@sha256:b3c656d55d7ad751196f21b7fd2e8d4da9cb430e32f646adcf92441b72f82b14

# Copy simple nginx configuration for Invoice Ninja FastCGI proxy
COPY ops/docker/nginx/config/default.conf /etc/nginx/conf.d/default.conf

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Use nginx default user and configuration
EXPOSE 80
