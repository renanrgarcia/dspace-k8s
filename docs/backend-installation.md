# DSpace 9 Backend Installation Guide

This document provides step-by-step instructions for installing DSpace 9 backend following the official documentation.

## Installation Process Overview

The DSpace 9 backend installation follows these main steps according to the official documentation:

### 1. Prerequisites (✅ Completed)

- **Java 17** - OpenJDK Eclipse Temurin (REQUIRED)
- **Maven 3.8+** - Using 3.9.9 (latest stable)
- **Ant 1.10+** - Latest version from Ubuntu packages
- **PostgreSQL 14-17** - Using PostgreSQL 17 with pgcrypto
- **Solr 9.x** - Using Solr 9.8 (latest 9.x series)

### 2. Source Code Preparation

The setup script automatically:

- Downloads DSpace 9.0 source code from GitHub
- Extracts to `/dspace-source` directory
- Sets proper ownership and permissions

### 3. Configuration (local.cfg)

Creates a comprehensive `local.cfg` file with:

- Database connection settings
- Solr server configuration
- Server URLs and hostname
- Mail configuration
- Authentication settings
- CORS settings for frontend integration

### 4. Build Process

Using Maven with optimized settings:

```bash
mvn clean package -Dmirage2.on=true -DskipTests
```

- **Mirage 2**: Enabled for modern responsive themes
- **Skip Tests**: Faster build for development
- **Memory**: 3GB max heap for optimal performance

### 5. Installation Process

Using Ant for fresh installation:

```bash
ant fresh_install
```

This installs DSpace to `/dspace` directory with all required components.

### 6. Database Initialization

- Runs database migration: `dspace database migrate`
- Creates all required tables and indexes
- Sets up the DSpace schema

### 7. Administrator Account

Creates default administrator account:

- **Email**: admin@dspace.org
- **Password**: admin
- **Role**: Site Administrator

### 8. Search Index

Builds the discovery search index:

```bash
dspace index-discovery -b
```

This creates the Solr cores and indexes for search functionality.

## Key Configuration Details

### Database Configuration

```properties
# PostgreSQL 17 with optimized settings
db.driver = org.postgresql.Driver
db.dialect = org.hibernate.dialect.PostgreSQLDialect
db.url = jdbc:postgresql://dspace-db:5432/dspace
db.username = dspace
db.password = dspace
db.maxconnections = 30
db.maxwait = 5000
db.maxidle = 10
```

### Solr Configuration

```properties
# Solr 9.8 configuration
solr.server = http://dspace-solr:8983/solr
```

### Server URLs

```properties
# Backend and frontend URLs
dspace.server.url = http://localhost:8080/server
dspace.ui.url = http://localhost:4000
dspace.hostname = localhost
dspace.baseUrl = http://localhost:8080
```

### Security Settings

```properties
# Authentication and CORS
authentication-password.domain.valid = localhost
cors.allowed-origins = http://localhost:4000,http://localhost:3000
```

## Runtime Configuration

### Spring Boot Application

DSpace 9 uses Spring Boot with embedded Tomcat:

- **Port**: 8080
- **Context Path**: /server
- **Health Check**: /server/actuator/health

### Java Runtime Settings

```bash
JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

### Environment Variables

- `POSTGRES_HOST`: Database hostname
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password
- `SOLR_HOST`: Solr hostname
- `SOLR_PORT`: Solr port
- `ADMIN_EMAIL`: Administrator email
- `ADMIN_PASSWORD`: Administrator password

## Verification Steps

The installation includes comprehensive verification:

1. **Service Dependencies**: Waits for PostgreSQL and Solr
2. **File Verification**: Checks for required executables and JARs
3. **Database Check**: Verifies schema and table count
4. **Solr Check**: Confirms connectivity and cores
5. **Version Check**: Displays DSpace version information

## Available Endpoints

After successful installation and startup:

- **REST API**: http://localhost:8080/server/api
- **OAI-PMH**: http://localhost:8080/server/oai
- **OpenAPI Docs**: http://localhost:8080/server/api/openapi.yml
- **Health Check**: http://localhost:8080/server/actuator/health

## Logging and Monitoring

- **Log Directory**: `/dspace/log/`
- **Configuration**: `/dspace/config/log4j2.xml`
- **Health Checks**: Built-in Spring Boot Actuator
- **Container Logs**: Available via `docker-compose logs`

## Troubleshooting

Common issues and solutions:

1. **Build Failures**: Check Maven heap settings and network connectivity
2. **Database Connection**: Verify PostgreSQL is running and accessible
3. **Solr Issues**: Confirm Solr cores are created and accessible
4. **Permission Problems**: Ensure proper file ownership and permissions

## Next Steps

After successful backend installation:

1. Test REST API endpoints
2. Verify database connectivity
3. Check Solr search functionality
4. Prepare for frontend installation
5. Configure for production deployment

This installation follows the official DSpace 9.x documentation and provides a solid foundation for development and testing.
