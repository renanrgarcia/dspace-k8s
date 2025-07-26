# DSpace Frontend Multi-stage Dockerfile
# Based on DSpace 9.x documentation requirements

# =============================================================================
# STAGE 1: Builder - Node.js environment for building Angular application
# =============================================================================
FROM node:18-alpine AS builder

# Install system dependencies needed for building
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Build arguments for configuration
ARG DSPACE_UI_HOST=localhost
ARG DSPACE_UI_PORT=4000
ARG DSPACE_REST_HOST=dspace-backend
ARG DSPACE_REST_PORT=8080
ARG DSPACE_REST_NAMESPACE=/server
ARG DSPACE_REST_SSL=false

# Environment variables for build
ENV DSPACE_UI_HOST=${DSPACE_UI_HOST}
ENV DSPACE_UI_PORT=${DSPACE_UI_PORT}
ENV DSPACE_REST_HOST=${DSPACE_REST_HOST}
ENV DSPACE_REST_PORT=${DSPACE_REST_PORT}
ENV DSPACE_REST_NAMESPACE=${DSPACE_REST_NAMESPACE}
ENV DSPACE_REST_SSL=${DSPACE_REST_SSL}

# Create app directory and set proper ownership
RUN mkdir -p /app && chown -R node:node /app

# Set working directory
WORKDIR /app

# Switch to node user for security
USER node

# Copy DSpace Angular source code from the build context
# Note: The build context now includes the entire project root
COPY --chown=node:node ./dspace-angular/ ./

# Copy Docker-specific configuration files
COPY --chown=node:node ./docker/dspace-frontend/config/ ./config/

# Install dependencies (including devDependencies for build)
RUN npm ci && npm cache clean --force

# Set Node.js memory limit for build process
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Build the Angular application for production (DSpace specific build)
RUN npm run build:prod

# =============================================================================
# STAGE 2: Runtime - Node.js environment for serving SSR application
# =============================================================================
FROM node:18-alpine AS runtime

# Install dependencies for health checks and debugging
RUN apk add --no-cache curl

# Create app user and directory
RUN addgroup -g 1001 -S nodejs && adduser -S dspace -u 1001 -G nodejs
RUN mkdir -p /app && chown -R dspace:nodejs /app

# Copy built application from builder stage
COPY --from=builder --chown=dspace:nodejs /app/dist /app/dist
COPY --from=builder --chown=dspace:nodejs /app/package.json /app/package.json
COPY --from=builder --chown=dspace:nodejs /app/config /app/config
COPY --from=builder --chown=dspace:nodejs /app/node_modules /app/node_modules

# Copy init script from the docker directory
COPY --chown=dspace:nodejs ./docker/dspace-frontend/init.sh /app/init.sh
RUN chmod +x /app/init.sh

# Set working directory
WORKDIR /app

# Runtime arguments that can be overridden
ARG DSPACE_UI_HOST=localhost
ARG DSPACE_UI_PORT=4000
ARG DSPACE_REST_HOST=dspace-backend
ARG DSPACE_REST_PORT=8080
ARG DSPACE_REST_NAMESPACE=/server
ARG DSPACE_REST_SSL=false

# Set environment variables for runtime
ENV NODE_ENV=production
ENV DSPACE_UI_HOST=${DSPACE_UI_HOST}
ENV DSPACE_UI_PORT=${DSPACE_UI_PORT}
ENV DSPACE_REST_HOST=${DSPACE_REST_HOST}
ENV DSPACE_REST_PORT=${DSPACE_REST_PORT}
ENV DSPACE_REST_NAMESPACE=${DSPACE_REST_NAMESPACE}
ENV DSPACE_REST_SSL=${DSPACE_REST_SSL}

# Switch to app user
USER dspace

# Expose port 4000 (DSpace frontend default)
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:4000/health || exit 1

# Start the DSpace Angular server via init script
CMD ["/app/init.sh"]
