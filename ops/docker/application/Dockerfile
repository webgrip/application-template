# Application Dockerfile Template
# Customize this file based on your application's technology stack

# Example for Node.js application
FROM node:20.10.0-alpine AS base

# Set working directory
WORKDIR /app

# Add application user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S app -u 1001

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application source
COPY --chown=app:nodejs src/ ./src/

# Set user
USER app

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start application
CMD ["node", "src/index.js"]