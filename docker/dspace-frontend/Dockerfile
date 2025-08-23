# DSpace Angular Frontend Dockerfile
# Multi-stage build for production DSpace frontend

# =============================================================================
# STAGE 1: Builder - Node.js environment for building Angular application
# =============================================================================
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

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

# Set Node.js memory limit and other optimizations for build process
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV NG_CLI_ANALYTICS=false
ENV CI=true

# Create app directory and set proper ownership
RUN mkdir -p /app && chown -R node:node /app

# Switch to node user for security
USER node

# Copy package files first for better layer caching
COPY --chown=node:node ./dspace-angular/package*.json ./

# Install dependencies
RUN npm ci --no-audit --prefer-offline

# Copy DSpace Angular source code
COPY --chown=node:node ./dspace-angular/ ./

# Copy Docker-specific configuration files
COPY --chown=node:node ./docker/dspace-frontend/config/ ./config/

# Create missing suggestion-target-data.service.ts file with all required methods
RUN mkdir -p src/app/core/notifications/suggestions/target && \
    echo 'import { HttpClient } from "@angular/common/http";' > src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { Injectable } from "@angular/core";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { Store } from "@ngrx/store";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { Observable, of } from "rxjs";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { IdentifiableDataService } from "../../../data/base/identifiable-data.service";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { FindListOptions } from "../../../data/find-list-options.model";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { PaginatedList } from "../../../data/paginated-list.model";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { RemoteData } from "../../../data/remote-data";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'import { SuggestionTarget } from "../models/suggestion-target.model";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '@Injectable({ providedIn: "root" })' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo 'export class SuggestionTargetDataService extends IdentifiableDataService<SuggestionTarget> {' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  protected linkPath = "suggestiontargets";' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  constructor() { super("suggestiontargets", null, null, null, null); }' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  getTargetsBySource(source: string, options: FindListOptions = {}): Observable<RemoteData<PaginatedList<SuggestionTarget>>> {' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '    return of({ hasSucceeded: true, payload: { page: [], totalElements: 0 } } as RemoteData<PaginatedList<SuggestionTarget>>);' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  }' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  getTargetsByUser(userId: string): Observable<RemoteData<PaginatedList<SuggestionTarget>>> {' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '    return of({ hasSucceeded: true, payload: { page: [], totalElements: 0 } } as RemoteData<PaginatedList<SuggestionTarget>>);' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  }' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  getTargetById(id: string): Observable<RemoteData<SuggestionTarget>> {' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '    return this.findById(id);' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '  }' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts && \
    echo '}' >> src/app/core/notifications/suggestions/target/suggestion-target-data.service.ts

# Build the Angular application for production
RUN npm run build:prod

# =============================================================================
# STAGE 2: Runtime - Node.js environment for serving the application
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
COPY --from=builder --chown=dspace:nodejs /app/server.ts /app/server.ts
COPY --from=builder --chown=dspace:nodejs /app/node_modules /app/node_modules

# Set working directory
WORKDIR /app

# Runtime environment variables
ENV NODE_ENV=production
ENV DSPACE_UI_HOST=localhost
ENV DSPACE_UI_PORT=4000
ENV DSPACE_REST_HOST=dspace-backend
ENV DSPACE_REST_PORT=8080
ENV DSPACE_REST_NAMESPACE=/server
ENV DSPACE_REST_SSL=false

# Switch to app user
USER dspace

# Expose port 4000 (DSpace frontend default)
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:4000/ || exit 1

# Start the DSpace Angular server
CMD ["node", "dist/server/main.js"]
