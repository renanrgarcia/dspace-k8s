# DSpace 9 Backend Dockerfile - Downloads and builds DSpace from official source
# Multi-stage build for production-ready DSpace backend

# =============================================================================
# STAGE 1: Builder - Downloads, configures and builds DSpace
# =============================================================================
FROM eclipse-temurin:17-jdk-jammy AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    ant \
    postgresql-client \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.x
ARG MAVEN_VERSION=3.9.9
RUN wget https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -P /tmp \
    && tar xf /tmp/apache-maven-*.tar.gz -C /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm /tmp/apache-maven-*.tar.gz

# Set environment variables
ENV MAVEN_HOME=/opt/maven
ENV PATH="$MAVEN_HOME/bin:$PATH"
ENV JAVA_HOME=/opt/java/openjdk
ENV MAVEN_OPTS="-Xmx3g -Xms1g -XX:MaxMetaspaceSize=512m"

# Build arguments for configuration
ARG DSPACE_VERSION=dspace-9.1
ARG POSTGRES_HOST=dspace-postgres
ARG POSTGRES_DB=dspace
ARG POSTGRES_USER=dspace
ARG POSTGRES_PASSWORD=dspace
ARG SOLR_HOST=dspace-solr
ARG SOLR_PORT=8983
ARG ADMIN_EMAIL=admin@dspace.org
ARG ADMIN_PASSWORD=admin

# Create directories and user
RUN useradd -m -s /bin/bash dspace
RUN mkdir -p /dspace-source /dspace && chown -R dspace:dspace /dspace-source /dspace

# Copy DSpace source from local directory
WORKDIR /dspace-source
COPY --chown=dspace:dspace ./dspace-source/ ./

# Switch to dspace user for build
USER dspace

# Build DSpace (skip tests for faster builds)
RUN mvn --no-transfer-progress clean package -P-test-environment -Denforcer.skip=true -Dcheckstyle.skip=true -DskipTests=true

# Install DSpace
RUN cd /dspace-source/dspace/target/dspace-installer \
    && ant fresh_install

# =============================================================================
# STAGE 2: Runtime - Lightweight runtime environment
# =============================================================================
FROM eclipse-temurin:17-jre-jammy AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create dspace user and directories
RUN useradd -m -s /bin/bash dspace \
    && mkdir -p /dspace/log \
    && chown -R dspace:dspace /dspace

# Copy DSpace installation from builder stage
COPY --from=builder --chown=dspace:dspace /dspace /dspace

# Copy configuration template
COPY --chown=dspace:dspace ./docker/dspace-backend/local.cfg.template /dspace/config/local.cfg

# Set runtime environment variables
ENV JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
ENV SPRING_PROFILES_ACTIVE="docker"
ENV DSPACE_INSTALL_DIR="/dspace"

# Runtime arguments that can be overridden
ARG POSTGRES_HOST=dspace-postgres
ARG POSTGRES_DB=dspace
ARG POSTGRES_USER=dspace
ARG POSTGRES_PASSWORD=dspace
ARG SOLR_HOST=dspace-solr
ARG SOLR_PORT=8983
ARG ADMIN_EMAIL=admin@dspace.org
ARG ADMIN_PASSWORD=admin

# Set environment variables for runtime
ENV POSTGRES_HOST=${POSTGRES_HOST}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV SOLR_HOST=${SOLR_HOST}
ENV SOLR_PORT=${SOLR_PORT}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}

# Switch to dspace user
USER dspace
WORKDIR /dspace

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
    CMD curl -f http://localhost:8080/server/actuator/health || exit 1

# Copy and set up the init script
COPY --chown=dspace:dspace ./docker/dspace-backend/init.sh /dspace/init.sh
RUN chmod +x /dspace/init.sh

# Use the init script as the entry point
CMD ["/dspace/init.sh"]
